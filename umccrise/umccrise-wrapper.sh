#!/bin/bash
set -euxo pipefail

# NOTE: This script expects the following variables to be set on the environment
# - S3_INPUT_DIR      : The bcbio directory (S3 prefix) for which to run UMCCRise
# - S3_DATA_BUCKET    : The S3 bucket that holds the above data
# - S3_RESULT_BUCKET  : The S3 bucket that recieves the result data
# - S3_REFDATA_BUCKET : The S3 bucket for the reference data expected by UMCCRise
# - CONTAINER_VCPUS   : The number of vCPUs to assign to the container (for metric logging only)
# - CONTAINER_MEM     : The memory to assign to the container (for metric logging only)

# For backwards compatibility
if [ ! -n "${S3_RESULT_BUCKET+1}" ]; then
    S3_RESULT_BUCKET="$S3_DATA_BUCKET"
fi

# NOTE: this setup is NOT setup for multiple jobs per instance. With multiple jobs running in parallel
# on the same instance there could be issues related to shared volume/disk space, shared memeory space, etc

# TODO: could parallelise some of the setup steps?
#       i.e. download and unpack all ref data in parallel

export AWS_DEFAULT_REGION="ap-southeast-2"
CLOUDWATCH_NAMESPACE="UMCCRISE"
CONTAINER_MOUNT_POINT="/work"
INSTANCE_TYPE=$(curl http://169.254.169.254/latest/meta-data/instance-type/)
AMI_ID=$(curl http://169.254.169.254/latest/meta-data/ami-id/)
UMCCRISE_VERSION=$(umccrise --version | sed 's/umccrise, version //') #get rid of unnecessary version text


function timer { # arg?: command + args
    start_time="$(date +%s)"
    $@
    end_time="$(date +%s)"
    duration="$(( $end_time - $start_time ))"
}

function publish { #arg 1: metric name, arg 2: value
    disk_space=$(df  | grep "${CONTAINER_MOUNT_POINT}$" | awk '{print $3}')

    aws cloudwatch put-metric-data \
    --metric-name ${1} \
    --namespace $CLOUDWATCH_NAMESPACE \
    --unit Seconds \
    --value ${2} \
    --dimensions InstanceType=${INSTANCE_TYPE},AMIID=${AMI_ID},UMCCRISE_VERSION=${UMCCRISE_VERSION},S3_INPUT="${S3_DATA_BUCKET}/${S3_INPUT_DIR}",S3_REFDATA_BUCKET=${S3_REFDATA_BUCKET},CONTAINER_VCPUS=${CONTAINER_VCPUS},CONTAINER_MEM=${CONTAINER_MEM},DISK_SPACE=${disk_space}
}

sig_handler() {
    exit_status=$?  # Eg 130 for SIGINT, 128 + (2 == SIGINT)
    echo "Trapped signal $exit_status. Exiting."
    exit "$exit_status"
}
trap sig_handler INT HUP TERM QUIT EXIT



timestamp="$(date +%s)"
instance_type="$(curl http://169.254.169.254/latest/meta-data/instance-type/)"

echo "Processing $S3_INPUT_DIR in bucket $S3_DATA_BUCKET with refdata from ${S3_REFDATA_BUCKET}"

avail_cpus="${1:-1}"
echo "Using  ${avail_cpus} CPUs."

# create a job specific output directory
job_output_dir=/work/output/${S3_INPUT_DIR}-${timestamp}

mkdir -p /work/{bcbio_project,${job_output_dir},panel_of_normals,pcgr,seq,tmp,validation}


echo "PULL ref data from S3 bucket"
timer aws s3 sync --only-show-errors s3://${S3_REFDATA_BUCKET}/genomes/ /work/genomes
publish S3PullRefGenome $duration

echo "PULL input (bcbio results) from S3 bucket"
timer aws s3 sync --only-show-errors --exclude=* --include=final/* --include=config/* s3://${S3_DATA_BUCKET}/${S3_INPUT_DIR} /work/bcbio_project/${S3_INPUT_DIR}/
publish S3PullInput $duration

echo "umccrise version:"
umccrise --version

echo "RUN umccrise"
timer umccrise /work/bcbio_project/${S3_INPUT_DIR} -j ${avail_cpus} -o ${job_output_dir} --no-igv --genomes /work/genomes
publish RunUMCCRISE $duration

echo "PUSH results"
timer aws s3 sync --delete --only-show-errors ${job_output_dir} s3://${S3_RESULT_BUCKET}/${S3_INPUT_DIR}/umccrised
publish S3PushResults $duration

echo "Cleaning up..."
rm -rf "${job_output_dir}"

echo "All done."

