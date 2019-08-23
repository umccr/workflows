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
S3_DATA_BUCKET=umccr-primary-data-prod/Patients
S3_WGS_INPUT_DIR=PM3056445/WGS/2019-08-09/umccrised/PM3056445__MDX190101_DNA052297-T
SAMPLE_BASE=${S3_WGS_INPUT_DIR##*/}
S3_WTS_INPUT_DIR=PM3056445/WTS/2019-08-12/final/MDX190102_RNA010943
S3_REFDATA_BUCKET=umccr-misc-temp/WTS-report/data

# Preparing umccrise data variables
PCGR=$(aws s3 ls s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/pcgr/ | grep somatic.pcgr.snvs_indels.tiers.tsv)
PURPLE=$(aws s3 ls s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/purple/ | grep purple.gene.cnv)
STRUCTURAL=$(aws s3 ls s3://${S3_DATA_BUCKET}/${S3_WGS_INPUT_DIR}/structural/ | grep manta.cnv)

export AWS_DEFAULT_REGION="ap-southeast-2"
CONTAINER_MOUNT_POINT="/work"

echo "Processing $S3_WTS_INPUT_DIR in bucket $S3_DATA_BUCKET with refdata from ${S3_REFDATA_BUCKET}"

# create a job specific output directory
job_output_dir=/work/output/

echo "PULL ref data from S3 bucket"
aws s3 sync --only-show-errors s3://${S3_REFDATA_BUCKET}/ /work/ref_data/

echo "PULL input (bcbio WTS results) from S3 bucket"
aws s3 sync --only-show-errors --exclude=salmon/* --exclude qc/* --excude *.bam s3://${S3_DATA_BUCKET}/${S3_WTS_INPUT_DIR}/ /work/WTS_data/

echo "PULL umccrise data from S3 bucket"
aws s3 sync --only-show-errors ${PCGR} /work/umccrise/pcgr/
aws s3 sync --only-show-errors ${PURPLE} /work/umccrise/purple/
aws s3 sync --only-show-errors ${STRUCTURAL} /work/umccrise/structural/

echo "RUN WTS-report"
Rscript /rmd_files/RNAseq_report.R --sample_name ${SAMPLE_BASE}  --dataset paad  --count_file /work/WTS_data/kallisto/abundance.tsv --report_dir /work/output/  --umccrise /work/umccrise/ --ref_data_dir /work/ref_data/

echo "PUSH results"
aws s3 sync --delete --only-show-errors ${job_output_dir} s3://${S3_DATA_BUCKET}/${S3_WTS_INPUT_DIR}/WTS-report

echo "Cleaning up..."
rm -rf "${job_output_dir}"

echo "All done."
END

sudo chmod 755 /opt/container/umccrise-wrapper.sh
