#!/bin/bash
# credit where is due: https://aws.amazon.com/blogs/compute/building-high-throughput-genomic-batch-workflows-on-aws-batch-layer-part-3-of-4/
set -euxo pipefail

export STACK="umccrise"
export INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type/)

################################################################################
# Put a wrapper script in place to run the tool inside the job container
# It can define pre/post processing steps around the actual tool inside
# the container, without having to bake this behaviour into the container itself.
# The job definition makes it available to the container (volume/mount)
# and defines how to call it (command).
sudo mkdir /opt/container

sudo tee /opt/container/umccrise-wrapper.sh << 'END'
#!/bin/bash
set -euxo pipefail

# NOTE: This script expects the following variables to be set on the environment
# - S3_INPUT_DIR      : The bcbio directory (S3 prefix) for which to run UMCCRise
# - S3_DATA_BUCKET    : The S3 bucket that holds the above data
# - S3_REFDATA_BUCKET : The S3 bucket for the reference data expected by UMCCRise
# - CONTAINER_VCPUS   : The number of vCPUs to assign to the container (for metric logging only)
# - CONTAINER_MEM     : The memory to assign to the container (for metric logging only)


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
timer aws s3 sync --delete --only-show-errors ${job_output_dir} s3://${S3_DATA_BUCKET}/${S3_INPUT_DIR}/umccrised
publish S3PushResults $duration

echo "Cleaning up..."
rm -rf "${job_output_dir}"

echo "All done."
END

sudo chmod 755 /opt/container/umccrise-wrapper.sh


################################################################################
# Create and mount a data volumn

if [[ $INSTANCE_TYPE =~ ^m5\..* ]]; then
    export AWS_DEV="/dev/sdf" 
elif [[ $INSTANCE_TYPE =~ ^m4\..* ]]; then
    export AWS_DEV="/dev/xvdb" 
else
    echo -e "Detected unsupported instance type ${INSTANCE_TYPE}.\nWe'll give this a whirl anyway. Defaulting AWS_DEV to /dev/xvdb."
    export AWS_DEV="/dev/xvdb" 
fi

# AWS instance introspection
export AWS_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_REGION=${AWS_AZ::-1}
export AWS_INSTANCE=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export AWS_VOL_TYPE="gp2"
export AWS_VOL_SIZE="500" # in GB

# Create a 500GB ST1 volume and fetch its ID
VOL_ID=$(sudo aws ec2 create-volume --region "$AWS_REGION" --availability-zone "$AWS_AZ" --encrypted --size "$AWS_VOL_SIZE" --volume-type "$AWS_VOL_TYPE" --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=batch}]' | jq -r .VolumeId)

# Wait for the volume to become available (block) and then attach it to the instance
aws ec2 wait volume-available --region "$AWS_REGION" --volume-ids "$VOL_ID" --filters Name=status,Values=available
aws ec2 attach-volume --region "$AWS_REGION" --device "$AWS_DEV" --instance-id "$AWS_INSTANCE" --volume-id "$VOL_ID"
aws ec2 wait volume-in-use --region "$AWS_REGION" --volume-ids "$VOL_ID" --filters Name=attachment.device,Values="$AWS_DEV"

# Make sure attached volume is removed post instance termination
aws ec2 modify-instance-attribute --region "$AWS_REGION" --instance-id "$AWS_INSTANCE" --block-device-mappings "[{\"DeviceName\": \"$AWS_DEV\",\"Ebs\":{\"DeleteOnTermination\":true}}]"

# Wait for $AWS_DEV to show up on the OS level. The above aws "ec2 wait" command is not reliable:
# ERROR: mount check: cannot open /dev/xvdb: No such file or directory
#
# XXX: Find a better way to do this :/
sleep 10

#This is pretty ugly, but required (for now) to leverage the new m5 instance types 
if [[ $INSTANCE_TYPE =~ ^m5\..* ]]; then
    hdparm -z /dev/nvme1n1
    mkfs.btrfs -f /dev/nvme1n1
    sudo echo -e "/dev/nvme1n1\t/mnt\tbtrfs\tdefaults\t0\t0" | sudo tee -a /etc/fstab
else
    mkfs.btrfs -f "$AWS_DEV"
    sudo echo -e "$AWS_DEV\t/mnt\tbtrfs\tdefaults\t0\t0" | sudo tee -a /etc/fstab
fi

# Format/mount

sudo mount -a


################################################################################
# Hard purge docker (meta)data and move docker storage to bigger volume
# XXX: Not the most efficient way to do this.
sudo systemctl stop docker
sudo rm -rf /var/lib/docker && sudo mkdir -p /var/lib/docker
sudo systemctl start docker # recreate basic docker overlay structure under /var/lib/docker
sudo systemctl stop docker
sudo mv /var/lib/docker /mnt/varlibdocker
sudo ln -sf /mnt/varlibdocker /var/lib/docker
sudo systemctl start docker


################################################################################
# Inject current AWS Batch underlying ECS cluster ID since the latter is dynamic. Match the computing environment with $STACK we are provisioning
# Note: this will fail in environments where no cluster exists, i.e. in debug/test environments
AWS_CLUSTER_ARN=$(aws ecs list-clusters --region "$AWS_REGION" --output json --query 'clusterArns' | jq -r .[] | grep "$STACK" | awk -F "/" '{ print $2 }')
if [[ ! -z "$AWS_CLUSTER_ARN" ]]; then
  sudo sed -i "s/ECS_CLUSTER=\"default\"/ECS_CLUSTER=$AWS_CLUSTER_ARN/" /etc/default/ecs
fi

# Restart systemd/docker service
sudo systemctl restart docker-container@ecs-agent.service

#Check if snap is installed, if so update amazon ssm agent
set +e
snap refresh amazon-ssm-agent --classic
set -e

