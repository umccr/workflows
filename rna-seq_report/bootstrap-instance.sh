#!/bin/bash
# credit where is due: https://aws.amazon.com/blogs/compute/building-high-throughput-genomic-batch-workflows-on-aws-batch-layer-part-3-of-4/
set -euxo pipefail

################################################################################
# Put a wrapper script in place to run the tool inside the job container
# It can define pre/post processing steps around the actual tool inside
# the container, without having to bake this behaviour into the container itself.
# The job definition makes it available to the container (volume/mount)
# and defines how to call it (command).
sudo mkdir /opt/container

sudo tee /opt/container/WTS-report-wrapper.sh << 'END'
#!/bin/bash
set -euxo pipefail

# NOTE: This script expects the following variables to be set on the environment
#S3_DATA_BUCKET=umccr-primary-data-prod/Patients
#S3_WGS_INPUT_DIR=PM3056445/WGS/2019-08-09/umccrised/PM3056445__MDX190101_DNA052297-T
#S3_WTS_INPUT_DIR=PM3056445/WTS/2019-08-12/final/MDX190102_RNA010943
# Will need to change this to a different variable, once we have a reference bucket in place for the WTS-reports.
# S3_REFDATA_BUCKET=umccr-misc-temp/WTS-report/data

# Preparing WGS input data - exists
if [ ! -z "$S3_WGS_INPUT_DIR" ]; then
    # Get rid of the trailing slash if exists in the input path
    S3_WGS_INPUT_DIR=${S3_WGS_INPUT_DIR%/}

    Extracting sample name from WGS container parameter passed by lambda function
    SAMPLE_WGS_BASE=${S3_WGS_INPUT_DIR##*/}

    # Preparing umccrise data variables - awk command is to strip off date-time details from the s3 ls and grep result
    PCGR=$(aws s3 ls s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/pcgr/ | grep somatic.pcgr.snvs_indels.tiers.tsv | awk '{print $4}')
    PURPLE=$(aws s3 ls s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/purple/ | grep purple.gene.cnv | awk '{print $4}')
    STRUCTURAL=$(aws s3 ls s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/structural/ | grep manta.tsv | awk '{print $4}')
    echo "PCGR: ${PCGR} PURPLE: ${PURPLE} STRUCTURAL: ${STRUCTURAL}"

    echo "PULL umccrise data from S3 bucket"
    aws s3 cp --only-show-errors s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/pcgr/${PCGR} /work/umccrise/${SAMPLE_WGS_BASE}/pcgr/
    aws s3 cp --only-show-errors s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/purple/${PURPLE} /work/umccrise/${SAMPLE_WGS_BASE}/purple/
    aws s3 cp --only-show-errors s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/structural/${STRUCTURAL} /work/umccrise/${SAMPLE_WGS_BASE}/structural/                                                          

else
    echo "Umccrise results on WGS data for the sample are not available"
fi

# Preapring WTS input data and directories

# Get rid of the trailing slash if exists in the input paths
S3_WTS_INPUT_DIR=${S3_WTS_INPUT_DIR%/}

# Extracting sample name from WTS container parameter passed by lambda function
SAMPLE_WTS_BASE=${S3_WTS_INPUT_DIR##*/}

# Prepare s3 output directory from WTS results input directory (go two levels up)
S3_OUTPUT_PATH=$(dirname $(dirname ${S3_WTS_INPUT_DIR}))
echo "S3_OUTPUT_PATH: ${S3_OUTPUT_PATH}"

export AWS_DEFAULT_REGION="ap-southeast-2"
CONTAINER_MOUNT_POINT="/work"

echo "Processing $S3_WTS_INPUT_DIR in bucket $S3_DATA_BUCKET with refdata from ${S3_REFDATA_BUCKET}"

# create a job specific output directory
job_output_dir=/work/output

# supposes reference data exists in '/WTS-report/data' inside the reference data bucket
echo "PULL ref data from S3 bucket"
aws s3 sync --only-show-errors s3://${S3_REFDATA_BUCKET}/WTS-report/data /work/WTS_ref_data

echo "PULL input (bcbio WTS results) from S3 bucket"
aws s3 sync --only-show-errors --exclude="salmon/*" --exclude "qc/*" --exclude "*.bam" s3://${S3_DATA_BUCKET}/${S3_WTS_INPUT_DIR}/ /work/WTS_data/${SAMPLE_WTS_BASE}

echo "RUN WTS-report"
#docker run --rm -v /work:/work umccr/wtsreport:0.1.2 Rscript /rmd_files/RNAseq_report.R --sample_name ${SAMPLE_WTS_BASE} --dataset paad  --bcbio_rnaseq /work/WTS_data/${SAMPLE_WTS_BASE} --report_dir ${job_output_dir}  --umccrise /work/umccrise/${SAMPLE_WGS_BASE} --ref_data_dir /work/WTS_ref_data
#check if umccrise results input is provided or not
if [ ! -z "$S3_WGS_INPUT_DIR" ]; then
    Rscript /rmd_files/RNAseq_report.R --sample_name ${SAMPLE_WTS_BASE} --dataset ${REF_DATASET}  --bcbio_rnaseq /work/WTS_data/${SAMPLE_WTS_BASE} --report_dir ${job_output_dir}  --umccrise /work/umccrise/${SAMPLE_WGS_BASE} --ref_data_dir /work/WTS_ref_data
else
    Rscript /rmd_files/RNAseq_report.R --sample_name ${SAMPLE_WTS_BASE} --dataset ${REF_DATASET}  --bcbio_rnaseq /work/WTS_data/${SAMPLE_WTS_BASE} --report_dir ${job_output_dir} --ref_data_dir /work/WTS_ref_data
fi

echo "PUSH results"
aws s3 sync --only-show-errors ${job_output_dir} s3://${S3_DATA_BUCKET}/${S3_OUTPUT_PATH}/wts-report

echo "Cleaning up..."
rm -rf "${job_output_dir}"

echo "All done."
END

sudo chmod 755 /opt/container/WTS-report-wrapper.sh

# Install and start docker service
#sudo yum update -y
#sudo amazon-linux-extras install docker -y
#sudo service docker start

# Add the ssm-user to the docker group 
#sudo usermod -a -G docker ssm-user
