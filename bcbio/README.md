# Bcbio commands trace

## Organize samples

n/a

## Alignment preparation
* Trim reads with atropos: remove polyX sequences at the 3' end (-a) in both read pairs (-A); also enabled NextSeq polyG filtering (--nextseq-trim) for good measure. Remove low quality bases (cutoff quality 5), and drop reads now shorter than 25 bases. See [Brad's blog spost](https://github.com/bcbio/bcbio_validations/tree/master/somatic_trim) for more details and overall motivation.
* Pipe into a bgzip FASTQ file and index with grabix.

# Alignment
* Taking blocks of reads from the (indexed) FASTQ files and aligning with bwa-mem. We are /discarding/ reads with >250 MEMs (maximal exact matches) in the genome, mark shorter split hits as secondary and set the RG. Other parameters left to default. This means reads will be soft-clipped.
* Aligned blocks are sorted with samtools sort by /read name/ and checked for consistency with samtools quickcheck.
* Tested blocks are merged with biobambam2's bamcat, and duplicate reads are marked with bamsormadup; the latter step also creates a BAM index (.bai).

# Callable regions
* Determine the callable regions, starting with the variant_regions file provided (in this case excluding the ALT regions of the reference genome), cleaning the BED file and creating merged, indexed regions (bedtools, tabix and Co).
* Repeat the same process for the coverage regions, and set svregions to variant_regions if not defined otherwise.
* Run mosdepth to determine which of the variant_regions have NO COVERAGE (0 reads), LOW_COVERAGE (1-3 reads) or are CALLABLE (4 reads or more). We are excluding reads with SAM FLAG 1804 (unmapped reads, mate unmapped, not primary alignment, fails QC check, marked duplicate) and require a non-zero mapping quality. The result is a quantitized BED file with regions of the same coverage level merged into single regions.
* If no variant_regions have been provided use the CALLABLE regions as variant_regions proxy
* Repeat for SV regions; also repeat for the coverage regions but write, for each region, the number of bases covered at 1, 5, 10, 20, 50, 100, 250, 500, 1000, 5000, 10000 or 50000 reads.
* Intersect all non-callable (nblock) regions from all samples in a batch, producing a global set of callable regions (batch-analysis_blocks.bed).

# Variant calling
* Variant calls are limited to CALLABLE regions (i.e., exclude LOW_COVERAGE). 
* Use bedtools subtract to remove low-complexity regions (if remove_lcr is set to true) from the callable regions.

### Vardict: Germline
* Call with vardict-java with an AF threshold of 10% (-f 0.1), ignoring reads with a mapping quality less than 10 (-Q 10), SAM FLAG x700 (-F 0x700, alignment is not primary, read is a duplicate, or fails vendor QC checks).
* Test for strand bias (teststrandbias.R)
* ?Neither the manual nor the paper explain exactly how strand bias is calculated, or what serves as a cutoff for PASS/No Pass?
* Convert from VarDict's format to VCF (var2vcf_valid.pl) keeping all variants at the same position (-A), and keeping only variant calls with QUAL >= 0
* ?Why remove QUAL 0 variant calls instead of setting the filter flag?
* Variants are then sorted and zipped / indexed

### Strelka2: Germline
* ?Strelka2 seems to be using different regions; commands start by referencing raw region BED files and make use of a -ploidy.vcf - unclear where they are generated?
* Configure the germline workflow given the callable regions and ploidy information for the region and call with default parameters
* Strelka doesn't need any flags to exclude reads by quality or other features, neither parameters for strand bias, allele frequency, or variant quality, because it's all already a part of the model it's trained on.

### Haplotype Caller: Germline
* Haplotype Caller runs with default parameters. For germline, ploidy is set to 2 (1 for Y), calling within the intersection of the BAM and each region.
* ?Caller /disables/ NotDuplicateReadFilter (which removes duplicate reads prior to calls)?
* Calls are annotated with a ton of different metrics (MappingQualityRankSumTest, MappingQualityZero, QualByDepth, ReadPosRankSumTest, RMSMappingQuality, BaseQualityRankSumTest, FisherStrand, MappingQuality, DepthPerAlleleBySample, Coverage, ClippingRankSumTest, DepthPerSampleHC)
* ?Again, no filtering of calls at this stage?

### Mutect2 caller: Somatic
* Mirrors the haplotype caller settings, calling at the intersection of BAM file and BED regions with ploidy 2 (1 for Y)
* Also disables the duplicated read filter
* ?Is this the recommended setting? Ploidy 1 for germline, 2 for somatic?
* Again, annotated with a lot of different metrics: ClippingRankSumTest, DepthPerSampleHC, MappingQualityRankSumTest, MappingQualityZero, QualByDepth, ReadPosRankSumTest, RMSMappingQuality, FisherStrand, MappingQuality, DepthPerAlleleBySample, Coverage
* Unlike Haplotype Caller this stage includes a filtering stage using FilterMutectCalls. See [GATK description of filters](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.6.0/org_broadinstitute_hellbender_tools_walkers_mutect_FilterMutectCalls.php).

### Vardict caller: Somatic
* Also uses vardict-java with a AF cutoff of 10% (-f 0.1), ignoring reads with a mapping quality less than 10 (-Q 10), SAM FLAG x700 (-F 0x700, alignment is not primary, read is a duplicate, or fails vendor QC checks).
* ?Instead of piping results into a strand bias check they get passed to testsomatic.R. Unclear what that actually does? Does that include a strand bias test?
* Convert from VarDict's format to VCF (var2vcf_paired.pl) using lenient calls (p-value 0.9, 4.25 mismatches allowed, somatic calls only). 
* ?And why remove QUAL 0 variant calls instead of setting the filter flag?

### Strelka2 Caller: Somatic
* Merge overlapping regions in target file 
* Set up and run workflow (configureStrelkaSomaticWorkflow.py) using default parameters
* Fix header with Picard




