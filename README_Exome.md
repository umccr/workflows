## UMCCR Exome-Seq workflow information



UMCCR bcbio pipeline
The bcbio workflow provides many options, e.g. in terms of aligners, variant callers or trimming steps. The following steps specifically discuss the UMCCR workflow.

Analysis steps
Alignment preparation
Reads are trimmed with atropos:
polyX sequences at the 3’ end in both read pairs are removed
Reads are filtered for polyG
Low quality bases (< 5) are removed, and reads shorter than 25 bases are dropped
Resulting reads are piped into a bgzip FASTQ file and indexed with grabix
Alignment
Blocks of reads are taken from the indexed FASTQ files and aligned with bwa-mem.  All reads > 250 maximal exact matches are discarded. Shorter split hits are marked as secondary. Reads are soft-clipped as per the default parameters.
Aligned blocks are sorted by read name with samtools, and checked for consistency with samtools quickcheck.
Tested blocks are merged with biobambam2’s bamcat, and duplicate reads are marked with bamsormadup and a BAM index (.bai) file is created.
Callable regions
Callable regions are defined using the variant_regions 
Variant calling
Variant calls are limited to callable regions, and only chromosomes 1-22, X, Y and MT (i.e. the standard chromosomes).
Vardict: germline
Variants are called with an AF threshold of 10%, and reads with a mapping quality of less than 10 are ignored
Output is converted to VCF using var2vcf_valid.pl, keeping all variants in the same position and keeping all variant  calls with QUAL >=0
VCFs are then sorted, zipped and indexed
Strelka2: germline
Run as default
HaplotypeCaller : germline
Runs with default parameters.
Variant representation is normalized between caller outputs. Normalization consists of three steps:
Split multi-allelic variants into separate single-allelic calls
Decompose biallelic block substitutions
Left-align and normalize indels
Bcbio supports majority voting ensemble approach to combining calls from multiple SNP and indel callers, leading to improved sensitivity. Specifically, for 3 variant callers, bcbio will keep only variants supported by at least 2 out of the 3 callers.
Post-processing of bcbio results.
Run MultiQC across the qc folders for each sample, to produce a single HTML report summarising multiple QC parameters


The pipeline produces a defined folder and file structure, as shown below. This defined standard structure ensures reproducibility of runs. Raw data (FASTQ files) are kept distinct from intermediate and final analysis results, enabling the pipeline to be re-run on demand without impacting on the raw data.

There are three folders:
config - configuration files for input samples
work - a directory for processing intermediate files
final - the final output of a bcbio run

The folder structure is detailed below:

bcbio_run/
    |-- config/
        |-- samples.csv
        |-- samples.yaml
        |-- bcbio_system.yaml
    |-- work/
        |-- align/
        |-- align_prep/
        |-- bcbiotx/
        |-- bedprep/
        |-- checkpoints_parallel/
        |-- coverage/
        |-- ensemble/
        |-- gatk-haplotype/
        |-- gemini/
        |-- log/
        |-- provenance/
        |-- qc/
        |-- regions/
        |-- trimmed/
        |-- run.sh
        |-- project_summary.yaml
    |-- final/
        |-- normal_sample/
        |-- year-month-daytimestamp_bcbio_run/
Key outputs
Alf files are labelled with the prefix:

Subject_SampleID_LibraryID

This prefix serves as a unique identifier.

Prefix.bam - a full processed alignment file, for visualization within IGV
Prefix.bam.bai - an index file for the BAM, required for visualization within IGV
Prefix.vcf.gz - a variant call format file, with VEP annotated variants.
Prefix.gaps.csv - a per sample file that specifies all regions below a predefined coverage threshold (default 20x). The gap analysis is created by scanning the diagnostic target region and identifying all contiguous stretches of bases that are covered with less than the threshold number of reads. For each such stretch (or “block”) of low coverage bases, a row is written to a comma separated text file, containing the length, the gene, the transcript information, the phenotype information and any known pathogenic variants in that region
Prefix.coverage.csv - a per sample file  that reports the observed mean and median coverage for the entire assay. Mean and median coverage levels that are not above expected thresholds are flagged, where median coverage should be > 50x and mean coverage should be > 80x.
TBA
