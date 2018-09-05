#!/bin/bash
# credit where is due: https://aws.amazon.com/blogs/compute/building-high-throughput-genomic-batch-workflows-on-aws-batch-layer-part-3-of-4/
set -euxo pipefail

export STACK="umccrise"
export AWS_DEV="/dev/xvdb" # XXX: Hardcoded for now since instance metadata is not consistent between t2, m4 and m5 instances. See:
# https://stackoverflow.com/questions/49891037/retrieve-correct-amazon-attached-ebs-device-from-instance-metadata-endpoint

# AWS instance introspection
export AWS_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_REGION=${AWS_AZ::-1}
export AWS_INSTANCE=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export AWS_VOL_TYPE="st1"
export AWS_VOL_SIZE="500" # in GB

# Create a 500GB ST1 volume and fetch its ID
VOL_ID=$(sudo aws ec2 create-volume --region "$AWS_REGION" --availability-zone "$AWS_AZ" --encrypted --size "$AWS_VOL_SIZE" --volume-type "$AWS_VOL_TYPE" | jq -r .VolumeId)

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

# Format/mount
sudo mkfs.btrfs -f "$AWS_DEV"
sudo echo -e "$AWS_DEV\t/mnt\tbtrfs\tdefaults\t0\t0" | sudo tee -a /etc/fstab
sudo mount -a

# Inject current AWS Batch underlying ECS cluster ID since the latter is dynamic. Match the computing environment with $STACK we are provisioning
AWS_CLUSTER_ARN=$(aws ecs list-clusters --region "$AWS_REGION" --output json --query 'clusterArns' | jq -r .[] | grep "$STACK" | awk -F "/" '{ print $2 }')
sudo sed -i "s/ECS_CLUSTER=\"default\"/ECS_CLUSTER=$AWS_CLUSTER_ARN/" /etc/default/ecs

# Restart systemd/docker service

sudo systemctl restart docker-container@ecs-agent.service

# now create a wrapper script to run the tool inside the job container
# this will be made available to the job container via the job definition (volume/mount)
# and will run the actual tool (wrapped in pre/post-processing steps)
sudo mkdir /opt/container

sudo tee /opt/container/umccrise-wrapper.sh << 'END'
#!/bin/bash
set -euxo pipefail

# make sure we don't have anything left over from previous runs
rm -rf /work/*

mkdir -p /work/{bcbio_project,output,panel_of_normals,pcgr,seq,tmp,validation}

echo "INPUT tarball: $S3_INPUT_OBJ"

echo "PULL ref FASTA from S3 bucket"
aws s3 sync --no-progress s3://umccr-umccrise-refdata-dev/Hsapiens/GRCh37/seq/ /work/seq/

echo "PULL panel of normals from S3 bucket"
aws s3 sync --no-progress s3://umccr-umccrise-refdata-dev/GRCh37/ /work/panel_of_normals/

echo "PULL truth_regions from S3 bucket"
aws s3 cp --no-progress s3://umccr-umccrise-refdata-dev/Hsapiens/GRCh37/validation/giab-NA12878/truth_regions.bed /work/validation/truth_regions.bed

echo "PULL PCGR reference data from S3 bucket"
aws s3 sync --no-progress s3://umccr-umccrise-refdata-dev/Hsapiens/GRCh37/PCGR/ /work/tmp/

echo "UNPACK the PCGR reference dataset"
tar xfz /work/tmp/*databundle*.tgz --directory=/work/pcgr

echo "FETCH input tarball (bcbio results) from S3 bucket"
aws s3 cp --no-progress s3://umccr-umccrise-dev/${S3_INPUT_OBJ} /work/tmp/

echo "UNPACK input tarball"
tar xfz /work/tmp/${S3_INPUT_OBJ} --directory=/work/bcbio_project

echo "REMOVE temp data"
rm -rf /work/tmp

echo "RUN umccrise"
umccrise /work/bcbio_project/${S3_INPUT_OBJ%.tar.gz} -o /work/output --pcgr /work/pcgr --ref-fasta /work/seq/GRCh37.fa --truth-regions /work/validation/truth_regions.bed --panel-of-normals /work/panel_of_normals

echo "PACK up the output"
tar cfz ${S3_INPUT_OBJ%.tar.gz}-output.tar.gz /work/output/*

echo "COPY the output to S3 bucket"
aws s3 cp ${S3_INPUT_OBJ%.tar.gz}-output.tar.gz s3://umccr-umccrise-dev/
END

sudo chmod 755 /opt/container/umccrise-wrapper.sh
