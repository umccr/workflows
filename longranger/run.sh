#!/bin/sh

. common/bootstrap-instance.sh

sudo tee /opt/container/stack-wrapper.sh << 'END'
#!/bin/bash
set -euxo pipefail

PRIMARY_DATA="s3://umccr-primary-data-dev"

# We really wish https://ewels.github.io/AWS-iGenomes/ was available in our Astralia (Sydney) region :_S
# Bezos, make it happen! ;)
REF_DATA="s3://umccr-umccrise-refdata-dev"
DST_DIR="/mnt"
CORES="40"
MEM="100"

# Install proper Perl-backed rename instead of the util-linux one
# https://unix.stackexchange.com/questions/256412/backreferences-in-rename-regex
sudo apt-get install rename

echo "INPUT dataset: $S3_INPUT_DIR"
echo "OUTPUT: ${DST_DIR}"

cd ${DST_DIR} && mkdir -p input ref output

echo "PULL dummy pre-called VCF to skip LR variant calling"
wget https://raw.githubusercontent.com/umccr/workflows/master/longranger/pre-called.vcf -O ${DST_DIR}/ref/pre-called.vcf

echo "PULL reference from S3 bucket"
aws s3 cp --no-progress ${REF_DATA}/10X/refdata-GRCh38-2.1.0.tar.gz ${DST_DIR}/ref

echo "UNPACK the PCGR reference dataset"
tar xfz ${DST_DIR}/refdata-*.tar.gz --directory=${DST_DIR}/ref

echo "FETCH input dataset from S3 bucket"
aws s3 sync --no-progress ${PRIMARY_DATA}/${S3_INPUT_DIR} ${DST_DIR}/${S3_INPUT_DIR}

echo "CONFORM to LR input filename schema"
rename 's/(.*)_(.*)_(.*)\.fastq\.gz/$1_$2_S1_L001_$3_001.fastq.gz/' *.fastq.gz

echo "RUN LongRanger"
time docker run --privileged -v $PWD/input:/data/input -v $PWD/ref/refdata-GRCh38-2.1.0:/data/refdata-GRCh38-2.1.0 -v $PWD/ref/pre-called.vcf:/data/ref/pre-called.vcf -v $PWD/output:/data/output -c ${CORES} umccr/longranger:2.2.2 wgs --id="output" --fastqs=/data/input --reference=/data/refdata-GRCh38-2.1.0 --jobmode=local --precalled=/data/ref/pre-called.vcf --disable-ui --localcores=${CORES} --localmem=${MEM}

echo "COPY the output back to S3 bucket"
aws s3 cp ${S3_INPUT_DIR}-output.tar.gz ${PRIMARY_DATA} 
END

sudo chmod 755 /opt/container/stack-wrapper.sh
