# DRAGEN Workflows

* [hg38 Reference Hash Tables](#hg38-reference-hash-tables)
* [Alignment and Fastq Input](#alignment-and-fastq-input)

## hg38 Reference Hash Tables

- hg38 FASTA downloaded from [1000 Genomes](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/)
  (see [this DRAGEN issue](https://github.com/umccr-illumina/dragen/issues/8)).
- Built using command below (via
  [this json body](https://github.com/umccr-illumina/stratus/blob/3de09e3fe63b076031c3e5a83013e0f91a6af7b7/TES/dragen_hg38_indexing.json)).

```bash
/opt/edico/bin/dragen \
  --build-hash-table true \
  --ht-reference /mount/index/hg38.fa \
  --ht-alt-liftover /opt/edico/liftover/bwa-kit_hs38DH_liftover.sam \
  --ht-build-rna-hashtable true \
  --enable-cnv true \
  --output-directory /mount/index/dragen
```

- Includes hash tables for RNAseq analysis and CNV analysis
- Hash table directory was then downloaded to Spartan, tar-archived, and uploaded to GDS using:

```bash
cd dir_with_ht_contents
tar -cvf hg38_dragen_ht.tar ./*
iap files upload hg38_dragen_ht.tar gds://umccr-refdata-dev/dragen/genomes/hg38/
```

- Contents of `gds://umccr-refdata-dev/dragen/genomes/hg38/`:

```

├ hg38.fa
├ hg38.fa.fai
├ ht/
  ├── anchored_rna
  │   ├── hash_table.cfg
  │   ├── hash_table.cfg.bin
  │   ├── hash_table.cmp
  │   ├── hash_table_stats.txt
  │   ├── reference.bin
  │   ├── ref_index.bin
  │   ├── repeat_mask.bin
  │   └── str_table.bin
  ├── hash_table.cfg
  ├── hash_table.cfg.bin
  ├── hash_table.cmp
  ├── hash_table_stats.txt
  ├── hg38_dragen_ht.tar
  ├── kmer_cnv.bin
  ├── reference.bin
  ├── ref_index.bin
  ├── repeat_mask.bin
  ├── replay.json
  ├── streaming_log.csv
  └── str_table.bin
```

## Alignment and FASTQ Input

* For a single run, only one BAM and VCF output files are produced because all input read groups are
expected to belong to the same sample. To process multiple samples from one BCL conversion run, run the
DRAGEN secondary analysis multiple times using different values for the `--fastq-list-sample-id` option for normal samples and `--tumor-fastq-list-sample-id` for tumour samples. For example:

```
/opt/edico/bin/dragen --partial-reconfig DNA-MAPPER --ignore-version-check true; \
mkdir -p /ephemeral/ref; \
tar -C /ephemeral/ref -xvf /mount/index/hg38/hg38_dragen_ht.tar; \
/opt/edico/bin/dragen \
--lic-instance-id-location /opt/instance-identity \
-f -r /ephemeral/ref \
--tumor-fastq-list /mount/fastqs/tumorFastqList.csv \
--fastq-list /mount/fastqs/normalFastqList.csv \
--output-directory /output/alignmentTest \
--output-file-prefix PM3062337
```

* The link to a complete TES task definition using above Dragen command is [here](https://github.com/umccr-illumina/stratus/blob/master/TES/dragen_alignment_on_bclConvert_output.json) 

* Additional summary on different Dragen parameters can be found in [Illumination](https://github.com/umccr/illumination/blob/master/docs/colo829/preparation.Rmd#L73).