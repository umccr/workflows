#!/bin/sh

. common/bootstrap-instance.sh

sudo tee /opt/container/stack-wrapper.sh << 'END'
#!/bin/bash
set -euxo pipefail

DST_DIR="/mnt"

echo "INPUT dataset: $S3_INPUT_DIR"
echo "OUTPUT: ${DST_DIR}"

cd ${DST_DIR} && mkdir -p input ref output

echo "PULL reference from S3 bucket"
aws s3 sync --no-progress s3://umccr-umccrise-refdata-dev/10X/refdata-GRCh38-2.1.0.tar.gz ${DST_DIR}/ref

echo "UNPACK the PCGR reference dataset"
tar xfz ${DST_DIR}/refdata-*.tar.gz --directory=${DST_DIR}/ref

# XXX: Just fetch a particular dataset, not the 1.5TB of multiple patients?
#echo "FETCH input dataset from S3 bucket"
#aws s3 sync --no-progress s3://umccr-umccrise-dev/${S3_INPUT_DIR} ${DST_DIR}/${S3_INPUT_DIR}

echo "RUN LongRanger"
time docker run --privileged -v $PWD/input:/data/input -v $PWD/ref/refdata-GRCh38-2.1.0:/data/refdata-GRCh38-2.1.0 -v $PWD/ref/pre-called.vcf:/data/pre-called.vcf -v $PWD/output:/data/output -c 95 umccr/longranger:2.2.2 wgs --id="output" --fastqs=/data/input --reference=/data/refdata-GRCh38-2.1.0 --jobmode=local --precalled=/data/pre-called.vcf --disable-ui --localcores=95 --localmem=350

# XXX: Just copy/report the resulting CSV for now since we only want the sample DNA nanograms?
#echo "COPY the output to S3 bucket"
#aws s3 cp ${S3_INPUT_DIR}-output.tar.gz s3://umccr-longranger-dev/
END

sudo chmod 755 /opt/container/stack-wrapper.sh
