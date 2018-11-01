#!/bin/bash
# credit where is due: https://aws.amazon.com/blogs/compute/building-high-throughput-genomic-batch-workflows-on-aws-batch-layer-part-3-of-4/
set -euxo pipefail

AGHA_BUCKETS="agha-gdr-staging-dev agha-gdr-store-dev"
export STACK="agha_batch"

# AWS instance introspection
export AWS_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_REGION=${AWS_AZ::-1}
export AWS_INSTANCE=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Inject current AWS Batch underlying ECS cluster ID since the latter is dynamic. Match the computing environment with $STACK we are provisioning
AWS_CLUSTER_ARN=$(aws ecs list-clusters --region "$AWS_REGION" --output json --query 'clusterArns' | jq -r .[] | grep "$STACK" | awk -F "/" '{ print $2 }')
sudo sed -i "s/ECS_CLUSTER=\"default\"/ECS_CLUSTER=$AWS_CLUSTER_ARN/" /etc/default/ecs

# Restart systemd/docker service

sudo systemctl restart docker-container@ecs-agent.service

# Mount the AGHA S3 buckets
for bucket in $AGHA_BUCKETS
do
  mkdir /mnt/$bucket
  s3fs -o iam_role -o allow_other -o mp_umask=0022 -o umask=0002 $bucket /mnt/$bucket
done



# Now create a wrapper script to run the tool inside the job container
# It can define pre/post processing steps around the actual tool inside
# the container, without having to bake this behaviour into the container itself.
# The job definition makes it available to the container (volume/mount)
# and defines how to call it (command).
sudo mkdir /opt/container

sudo tee /opt/container/agha-wrapper.sh << 'END'
#!/bin/bash
set -euxo pipefail

input_file=$1

BUCKET_ROOT="${BUCKET_ROOT:-/mnt/agha-gdr-staging-dev}"

if test -f $input_file; then
    echo "File not found! $input_file"
    exit 1
fi

if test -f ${input_file}.md5; then
    echo "Checksum file detected. Checking..."
    if ! md5sum -c ${input_file}.md5  &> /dev/null; then
        echo "ERROR: Checksum mismatch for $input_file"
        exit 1
    else
        echo "Checksum is OK for $input_file"
        exit 0
    fi
fi

md5sum $input_file > ${input_file}.md5

echo "All done."
END

sudo chmod 755 /opt/container/agha-wrapper.sh
