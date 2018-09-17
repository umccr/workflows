#!/bin/sh

sudo tee /opt/container/umccrise-wrapper.sh << 'END'
#!/bin/bash
set -euxo pipefail

# TODO: could parallelise some of the setup steps
#       i.e. download and unpack all ref data in parallel

# TODO: make the source and destination bucket configurable (and possibly the reference data bucket)
#       Possibly the full input/output path (including the bucket name)

## TODO: # of discovered CPUs instead of by parameter?

avail_cpus=1
if test ! -z $1; then
	avail_cpus=$1
fi

echo "Using  $avail_cpus CPUs."

# make sure we don't have anything left over from previous runs
# TODO: Could tweak that to keep refdata that does not change and save on download time
rm -rf /work/*

mkdir -p /work/{10X,output,tmp}

echo "INPUT dataset: $S3_INPUT_DIR"

echo "PULL ref FASTA from S3 bucket"
aws s3 sync --no-progress s3://umccr-umccrise-refdata-dev/10X/refdata-GRCh38-2.1.0.tar.gz /work/10X/

echo "UNPACK the PCGR reference dataset"
tar xfz /work/10X/refdata-*.tar.gz --directory=/work/10X

echo "FETCH input dataset from S3 bucket"
aws s3 sync --no-progress s3://umccr-umccrise-dev/${S3_INPUT_DIR} /work/bcbio_project/${S3_INPUT_DIR}

echo "RUN $STACK"
time docker run --privileged -v $PWD/COLO829BL:/data/COLO829BL -v $PWD/refdata-GRCh38-2.1.0:/data/refdata-GRCh38-2.1.0 -v $PWD/pre-called.vcf:/data/pre-called.vcf -v $PWD/output:/data/output -c 95 umccr/longranger:2.2.2 wgs --id="output" --fastqs=/data/COLO829BL --reference=/data/refdata-GRCh38-2.1.0 --jobmode=local --precalled=/data/pre-called.vcf --disable-ui --localcores=95 --localmem=350

echo "PACK up the output"
tar cfz ${S3_INPUT_DIR}-output.tar.gz /work/output/*

echo "COPY the output to S3 bucket"
aws s3 cp ${S3_INPUT_DIR}-output.tar.gz s3://umccr-longranger-dev/
END

sudo chmod 755 /opt/container/$STACK-wrapper.sh
