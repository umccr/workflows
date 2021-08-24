# workflows

UMCCR production workflows

[TOC]

## Preprocessing Workflow

* bcl2fastq
* bcl QC, interop stats
* Pointer to Google-LIMS config

## Primary WGS Processing Workflow with bcbio

* bcbio intro

### bcbio default hg38 config

The bcbio `YAML` configuration is kept [under version control](https://github.com/umccr/workflows/blob/master/configurations/std_workflow_cancer_hg38.yaml) and follows standard bcbio guidelines. The documentation below references the configuration as needed.

### Organize samples

* TBA (sample merging, topup handling, coverage targets)

### Alignment preparation

* Trim reads with `atropos`: remove polyX sequences at the 3' end (`-a`) in both read pairs (`-A`); also enabled NextSeq polyG filtering (`--nextseq-trim`) for good measure. Remove low quality bases (cutoff quality 5), and drop reads now shorter than 25 bases. See [Brad's blog post](https://github.com/bcbio/bcbio_validations/tree/master/somatic_trim) for more details and overall motivation.
* Pipe into a `bgzip` FASTQ file and index with `grabix`.

```
      # Poly-G filtering
      trim_reads: atropos
      adapters: polyx
```

### Alignment

* Taking blocks of reads from the (indexed) FASTQ files and aligning with `bwa-mem`. We are **discarding** reads with >250 MEMs (maximal exact matches) in the genome, mark shorter split hits as secondary and set the RG. Other parameters left to default. This means reads will be soft-clipped.
* Aligned blocks are sorted with `samtools sort` by _read name_ and checked for consistency with `samtools quickcheck`.
* Tested blocks are merged with biobambam2's `bamcat`, and duplicate reads are marked with `bamsormadup`; the latter step also creates a BAM index (`.bai`).

```
    genome_build: hg38
    algorithm:
      # Alignment parameters
      aligner: bwa
      recalibrate: false
      realign: false
      mark_duplicates: true
      remove_lcr: false
```

### Callable regions

* Determine the callable regions, starting with the `variant_regions` file provided (in this case excluding the ALT regions of the reference genome), cleaning the BED file and creating merged, indexed regions (`bedtools`, `tabix` and Co).
* Repeat the same process for the `coverage` regions, and set `svregions` to `variant_regions` if not defined otherwise.
* Run `mosdepth` to determine which of the `variant_regions` have `NO COVERAGE` (0 reads), `LOW_COVERAGE` (1-3 reads) or are `CALLABLE` (4 reads or more). We are excluding reads with SAM FLAG `1804` (unmapped reads, mate unmapped, not primary alignment, fails QC check, marked duplicate) and **require a non-zero mapping quality** (note the impact on ALT regions, [segmental duplications](#UMCCR-Cancer-Gene-List-and-Segmental-Duplications)). The result is a quantitized BED file with regions of the same coverage level merged into single regions.
* If no `variant_regions` have been provided use the `CALLABLE` regions as `variant_regions` proxy.
* Repeat for SV regions; also repeat for the coverage regions but write, for each region, the number of bases covered at 1, 5, 10, 20, 50, 100, 250, 500, 1000, 5000, 10000 or 50000 reads.
* Intersect all non-callable (`nblock)` regions from all samples in a batch, producing a global set of callable regions (`batch-analysis_blocks.bed`).

### Variant calling

* Variant calls are limited to `CALLABLE` regions (i.e., **exclude** `LOW_COVERAGE`).
* Use `bedtools subtract` to remove low-complexity regions (if `remove_lcr` is set to `true`) from the callable regions.

```
      # Variant calling, 2-out-of-3. All callers handle InDels
      variantcaller:
        germline: [vardict, strelka2, gatk-haplotype]
        somatic: [vardict, strelka2, mutect2]
      ensemble:
        numpass: 2

      # Call down to 1% allelic frequency
      min_allele_fraction: 1
```

**Standard Chromosomes only:**

Variants are being called for [chr1-22/X/Y/MT only](https://bcbio-nextgen.readthedocs.io/en/latest/contents/configuration.html#analysis-regions), i.e., limited to the standard chromosomes:

> `      exclude_regions: [altcontigs]`

We avoid calling variants in [alternative and unplaced contigs](https://github.com/lh3/bwa/blob/master/README-alt.md) completely to avoid slowdowns on those additional regions. This has implications for variants only found in non-reference haplotypes (see section on [ALT regions](#alt-handling)).

**Variant Blocklist:**

We also avoid regions in the [ENCODE 'blocklist'](https://github.com/Boyle-Lab/Blacklist) [hg38-blacklist.v2.bed.gz](https://github.com/Boyle-Lab/Blacklist/tree/master/lists) for SNV calling only:

> `      variant_regions: hg38_noalt_noBlacklist.bed`

This not only improves overall precision of our calls but also speeds up the variant calling process.

> hg38_noalt_noBlacklist.bed was supposed to be the result of bedtools subtract of hg38_noalt and the corresponding file in https://github.com/Boyle-Lab/Blacklist/tree/master/lists



#### Vardict: Germline

* Call with `vardict-java` with an AF threshold of 10% (`-f 0.1`), ignoring reads with a mapping quality less than 10 (`-Q 10`), SAM FLAG x700 (`-F 0x700`, alignment is not primary, read is a duplicate, or fails vendor QC checks).
* Test for strand bias (`teststrandbias.R`)

> _Neither the manual nor the paper explain exactly how strand bias is calculated, or what serves as a cutoff for PASS/No Pass?_

* Convert from VarDict's format to VCF (`var2vcf_valid.pl`) keeping all variants at the same position (`-A`), again filtering for AF (`-f 0.1`) and keeping only variant calls with `QUAL >= 0`

> _Why do we filter for AF again? And why remove QUAL 0 variant calls instead of setting the filter flag?_

* Variants are then sorted and zipped / indexed

#### Strelka2: Germline

* Configure the germline workflow given the callable regions and ploidy information for the region and call with default parameters

> _Strelka2 seems to be using different regions; commands start by referencing `raw` region BED files and make use of a `-ploidy.vcf` - unclear where they are generated?_
> _I am not seeing any filtering for AF or other parameters for Strelka (e.g., strand bias, variant quality); also not seeing any flags to exclude duplicated or low quality reads. I suppose Strelka2 does that by default?_

#### Haplotype Caller: Germline

* Haplotype Caller runs with default parameters. For germline, `ploidy` is set to `2` (1 for Y), calling within the intersection of the BAM and each region.

> _Caller disables NotDuplicateReadFilter (which removes duplicate reads prior to calls)?_

* Calls are annotated with a ton of different metrics (MappingQualityRankSumTest, MappingQualityZero, QualByDepth, ReadPosRankSumTest, RMSMappingQuality, BaseQualityRankSumTest, FisherStrand, MappingQuality, DepthPerAlleleBySample, Coverage, ClippingRankSumTest, DepthPerSampleHC)

> _Again, no filtering of calls at this stage?_

#### Mutect2 caller: Somatic

* Mirrors the haplotype caller settings, calling at the intersection of BAM file and BED regions with `ploidy 2` (1 for Y)
* Also disables the duplicated read filter
* Again, annotated with a lot of different metrics: ClippingRankSumTest, DepthPerSampleHC, MappingQualityRankSumTest, MappingQualityZero, QualByDepth, ReadPosRankSumTest, RMSMappingQuality,  FisherStrand, MappingQuality, DepthPerAlleleBySample, Coverage
* Unlike Haplotype Caller this stage includes a filtering stage using `FilterMutectCalls`. See [GATK description of filters](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.6.0/org_broadinstitute_hellbender_tools_walkers_mutect_FilterMutectCalls.php).

#### Vardict caller: Somatic

* Also uses `vardict-java` with a AF cutoff of 10% (`-f 0.1`), ignoring reads with a mapping quality less than 10 (`-Q 10`), SAM FLAG x700 (`-F 0x700`, alignment is not primary, read is a duplicate, or fails vendor QC checks).
* Instead of piping results into a strand bias check they get passed to `testsomatic.R`.

> _Unclear what that actually does? Does that include a strand bias test?_

* Convert from VarDict's format to VCF (`var2vcf_paired.pl`) using lenient calls (p-value 0.9, 4.25 mismatches allowed, somatic calls only).

> _Why do we filter for AF again? And why remove QUAL 0 variant calls instead of setting the filter flag?_

#### Strelka2 Caller: Somatic

* Merge overlapping regions in target file

> _Why is this only required here, but not for other callers?_

* Set up and run workflow (`configureStrelkaSomaticWorkflow.py`) using default parameters
* Fix header with Picard

### Variant Ensemble calling

TBA

### Structural Variant calling

#### Manta

* Configure Manta to run in Tumor/Normal mode.
  Options include generating a BAM file containing reads that support SVs
  (`--generateEvidenceBam`), and including assembled contig sequences in the
  final VCF file (`--outputContig`).
* Calling regions are specified as whole chromosomes (1-22, X, Y, M).

```
      svcaller: [manta]
      svprioritize: umccr_cancer_genes.latest.genes

resources:
  manta:
    options:
    - --generateEvidenceBam
    - --outputContig
```

#### BPI

* [BreakPointInspector](https://github.com/hartwigmedical/hmftools/tree/b8e9c3b32a3a3fa6bc1d88c7ced1e1ebaf715e4c/break-point-inspector)
is used to readjust the SV coordinates and apply soft filters for potential false positives inferred by Manta.
We also use its Allele Frequency calculations to apply additional filters.

```
      # Extras
      tools_on: [break-point-inspector]
```

**Questions:**

* [ ] Where do the `mosdepth` coverage statistics come from? bcbio or umccrise?
* [ ] Where is `peddy` being run?

**Todo:**

* [ ] Remove sections not applicable given our config?
* [ ] Quote / describe bcbio YAML configs

### QC

TBA (or move to umccrise section)

```
      # QC and coverage assessent
      coverage: umccr_cancer_genes.hg38.transcript.bed
```


## Changes to primary processing for FFPE samples

Low quality sampes -- particulalry FFPE -- use a slightly [modified bcbio configuration](https://github.com/umccr/workflows/blob/master/configurations/std_workflow_cancer_ffpe_hg38.yaml) to prevent the workflow from stalling in highly fragmented read regions. 

## WGS Postprocessing with umccrise

We develop and use the `umccrise` workflow to post-processes outputs from our bcbio-nextgen cancer variant calling analysis pipeline. In brief, umccrise steps include:

* Filter artefacts and germline leakage from somatic calls
* Run PCGR to annotate, prioritize and report somatic variants
* Run CPSR to annotate, prioritize and report germline variants
* Filter, annotate, prioritize and report SV
* Run PURPLE to call CNV, purity, ploidy, and recover SV
* Run Conpair to tumor/normal concordance and sample contamination

The workflow generates a number of different reports:

1. MultiQC report comparing QC to "reference" samples
2. Cancer Report with mutational signatures, strand bias analysis, PURPLE results, and prioritized SVs
3. CACAO to calculate coverage in common hotspots, as well as goleft to estimate coverage problems (germline, somatic)
4. CPSR for germline variant in predisposition gene prioritisation
5. PCGR for somatic variant prioritisation

The post-processing workflow is available on [Github](https://github.com/umccr/umccrise) and comes with [extensive documentation](https://github.com/umccr/umccrise/blob/master/workflow.md) of the workflow steps and a [version history](https://github.com/umccr/umccrise/blob/master/HISTORY.md). We summarize the different steps and outputs below but recommend referencing the main documentation as well.

**Todo:**

* [ ] Migrate [Google Doc](https://docs.google.com/document/d/1yBaSExF50pXk3P6Kl1SnIa_IQagD_Vu_-YOkxkHMB1Q/edit#) over to [Vlad's repo](https://github.com/umccr/umccrise/blob/master/workflow.md)
* [ ] Summarize workflow steps


## Reporting structure

* PCGR containing small somatic variants (SNPs and indels) classified according to ACMG guidelines, and MSI status of the sample.
* CPSR containing small germline variants (SNPs and indels) in cancer predisposition genes, ranked by ACMG guidelines and cancer-specific criteria.
* CACAO for tumor sample, reporting coverage for clinically actionable and pathogenic loci in cancer
* CACAO for normal sample, reporting coverage in likely pathogenic variants cancer predisposition protein-coding genes
* MultiQC report with QC stats and plots
* UMCCR cancer report containing:
  * Somatic mutation profile (global and in umccr genes),
  Mutational signatures (by the MutationalPatterns R package),
  * Structural variants,
  * Copy number variants,
  * PURPLE QC status,
  * Circos plot

**Todo:**

* [ ] Subheadings per report with some additional pointers and descriptions (where not already detailed in the report)
* [ ] Link to current SEQC-II report samples


## Gene Lists

The UMCCR workflows make extensive use of gene lists throughout the different processing and reporting steps. Gene lists are updated twice a year automatically prior to manual curation before being used in the production setting. Below we outline the gene lists currently in use.

### 1. UMCCR Cancer Gene List

UMCCR uses a core gene list ("UMCCR Cancer Gene List") to assess coverage of key genes, rescue low allelic frequency variants and to prioritize SV calls. This [core list](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/umccr_cancer_genes.latest.tsv) (latest version) is [automatically generated](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/make_umccr_cancer_genes.Rmd) from a number of different sources:

* [Cancermine](http://bionlp.bcgsc.ca/cancermine/) with at least 2 publications with at least 3 citations - [280 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/cancermine_collated.tsv)
* [NCG known cancer genes](http://ncg.kcl.ac.uk/cancer_genes.php#known) - [711 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/NCG6_cancergenes.tsv)
* [Tier 1 COSMIC Cancer Gene Census](https://cancer.sanger.ac.uk/cosmic/census?tier=1) (CGC) - [576 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/CancerGeneCensus_Tier1.tsv)
* UMCCR internal manually added genes - [1 gene](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/umccr.txt)
* Internally added genes based on presence in [CACAO hotspot genes](https://github.com/sigven/cacao) (curated from [ClinVar](https://www.ncbi.nlm.nih.gov/clinvar) (May 3rd 2019 release, [data](https://github.com/sigven/cacao/blob/master/data/cacao.clinvar_path.grch38.tsv)), [CiViC](https://civicdb.org/) (May 3rd 2019 retrieval, [data](https://github.com/sigven/cacao/blob/master/data/cacao.civic.grch38.tsv)) and [cancerhotspots](https://www.cancerhotspots.org/) (v2 release, [data](https://github.com/sigven/cacao/blob/master/data/cacao.hotspot.grch38.tsv))) - [1557 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/cacao.grch38.genes.txt) extracted from [full release](https://github.com/sigven/cacao/blob/master/data/cacao.grch38.bed) (BED)
* At least 2 matches in the following five databases and eight clinical panels:
    * Cancer predisposition genes, [CPSR panel0](https://github.com/sigven/cpsr#cancer-predisposition-genes) - [216 genes](https://github.com/sigven/cpsr/blob/master/predisposition.md) obtained from:
        * A list of 152 genes that were curated and established within TCGA’s pan-cancer study ([Huang et al., Cell, 2018](https://www.ncbi.nlm.nih.gov/pubmed/29625052))
        * A list of 107 protein-coding genes that has been manually curated in COSMIC’s [Cancer Gene Census v86](https://cancer.sanger.ac.uk/census) (all genes annotated as Hallmark and Germline),
        * A list of 148 protein-coding genes established by experts within the Norwegian Cancer Genomics Consortium ([http://cancergenomics.no](http://cancergenomics.no/))
    * Hartwig Medical Foundation [list of known fusions](https://nc.hartwigmedicalfoundation.nl/index.php/s/a8lgLsUrZI5gndd?path=%2FHMFTools-Resources%2FLINX) - [439 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/panelapp/HMF_fusions.tsv)
    * AZ300 (AstraZeneca cancer genes list) - [300 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/az_key_genes.300.txt)
    * Peter MacCallum Cancer Centre gene panel - [404 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/PMCC.genes)
    * COSMIC Cancer Gene Census ([tier 2](https://cancer.sanger.ac.uk/cosmic/census?tier=2)) - [147 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/CancerGeneCensus_Tier2.tsv)
    * Familial Cancer - [126 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/familial_cancer.genes)
    * [Illumina-TS500](https://emea.illumina.com/content/dam/illumina-marketing/documents/products/datasheets/trusight-oncology-500-data-sheet-1170-2018-010.pdf) - [523 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/TS500.genes)
    * [TEMPUS xt Gene Panel](https://www.tempus.com/wp-content/uploads/2018/12/xT-Gene-List_120618.pdf) - [594 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/TEMPUS.genes)
    * [OncoKB annotated](https://www.oncokb.org/cancerGenes) - [579 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/oncoKB_cancerGeneList.txt)
    * MSKC-IMPACT (from [oncoKb](https://www.oncokb.org/cancerGenes)) - [468 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/oncoKB_cancerGeneList.txt)
    * MSKC-Heme (from [oncoKb](https://www.oncokb.org/cancerGenes)) - [400 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/oncoKB_cancerGeneList.txt)
    * Foundation One (from [oncoKb](https://www.oncokb.org/cancerGenes)) - [322 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/oncoKB_cancerGeneList.txt)
    * Foundation Heme (from [oncoKb](https://www.oncokb.org/cancerGenes)) - [592 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/oncoKB_cancerGeneList.txt)
    * Vogelstein (from [oncoKb](https://www.oncokb.org/cancerGenes)) - [125 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/oncoKB_cancerGeneList.txt)

Gene lists for all of these sources can be found in the [sources](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources) folder. The combined list contains [1250 genes](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/umccr_cancer_genes.latest.tsv).

A BED file with transcript and coding regions coordinates is [automatically generated](https://github.com/umccr/workflows/blob/master/genes/cancer_genes/Snakefile) from the latest gene list
using coordinates from ENSEMBL. Transcript IDs for coordinate choices are selected using principal transcript annotations in [APPRIS](http://appris.bioinfo.cnio.es/#/). The APPRIS transcript IDs are downloaded from the APPRIS website and stored for versioning in [Github](https://github.com/umccr/workflows/blob/master/transcripts/). Chosen principal transcripts for each cancer gene are also added into the final generated gene table under the columns `PRINCIPAL_hg19` and `PRINCIPAL_hg38`.

**Gene List Usage:**

* bcbio SV prioritization: (xx Clarify interaction with umccrise)
* MultiQC for coverage assessment (General Statistics table) (xx canonical transcripts only?)
* Cancer Report: CDS of included genes for SNV Allelic Frequencies in Key Genes CDS
* Cancer Report: UMCCR Gene CNV Calls table
* Cancer Report (xx Anywhere else?)

**Note:** _All gene lists are in the process of being migrated to the [Australian PanelApp instance](https://panelapp.agha.umccr.org/)._

**Questions:**

* [ ] Do we have a source for the `Familiar Cancer` gene list?
* [ ] Which file from https://github.com/umccr/workflows/tree/master/genes/fusions is the source for the Hartwig fusions above?
* [ ] Version / source for the PMCC gene list?
* [ ] Cancer Report: Structural Variants table references oncogene, tsgene annotation. From which gene list is this coming from?
* [ ] Confirm coverage is based on `umccr_cancer_genes.hg38.transcript.bed`
* [ ] Clarify bcbio's `svprioritize` vs umccrise handling; which genes are we using here?

**Todo:**

* [ ] Switch from <https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/cacao.txt> to <https://github.com/umccr/workflows/blob/master/genes/cancer_genes/sources/cacao.grch38.bed> within <https://github.com/umccr/workflows/blob/master/genes/cancer_genes/make_umccr_cancer_genes.Rmd>
* [ ] Add links to PanelApp for each gene list, joint panel
* [ ] Lavinia, Georgie and I [Joep] did some comparisons of transcripts selected by APPRIS, MANE and PeterMac and found many differences. For consistency of reporting, alignment with PeterMac, and working with Pierian, we need to work out what is the best approach. From a curation efficiency point of view, it is also important to align with OncoKB and Cosmic as much as possible.


### 2. Custom Cancer Predisposition Gene List

To assess predisposition to cancer we use CPSR's [Cancer Predisposition Genes](https://github.com/sigven/cpsr/blob/master/predisposition.md) (Panel 0), a virtual panel of 216 genes based on the union of:

* [152 genes](https://github.com/umccr/workflows/blob/master/genes/predisposition_genes/panelapp/TCGA_PANCAN_2018.tsv) that were curated and established within TCGA’s pan-cancer study (TCGA_PANCAN_18 [Huang et al., Cell, 2018](https://www.ncbi.nlm.nih.gov/pubmed/29625052))
* [107 protein-coding genes](https://github.com/umccr/workflows/blob/master/genes/predisposition_genes/panelapp/CGC_86.tsv) that has been manually curated in COSMIC’s [Cancer Gene Census v86](https://cancer.sanger.ac.uk/census) (CGC_86),
* [148 protein-coding genes](https://github.com/umccr/workflows/blob/master/genes/predisposition_genes/panelapp/NCGC.tsv) established by experts within the Norwegian Cancer Genomics Consortium (NCGC, <http://cancergenomics.no>)

UMCCR have included the following 8 genes to this list, bringing the total to 209 + 8 = 217 genes:

* `TNFRSF6, KLLN, MAP3K6, NEK1, NTRK1, RAD54L, RHNO1, RTEL1`

We are considering a switch to the more specific virtual panels from Genomics England (see [panels 1-38](https://github.com/sigven/cpsr#cancer-predisposition-genes)) in the future.

**Gene List Usage:**

* CPSR: Variant tier assessment

**Questions:**

* [ ] Numbers don't add up - what's the final count _with_ the UMCCR additions?
* [ ] Where are UMCCR additions coming from? Can curate in PanelApp.

**Todo:**

* [ ] Add PMCC Mol Path germline list to PanelApp: `ALK, APC, ASXL1, ATM, BAP1, BCORL1, BLM, BRCA1, BRCA2, BRIP1, CBL, CDC73, CDH1, CDK4, CDKN1B, CDKN2A, CEBPA, CHEK2, CYLD, DICER1, DNMT3A, EGFR, ERCC2, FANCA, FANCC, FANCG, FH, FLCN, FUBP1, GATA2, GNAS, HRAS, IDH1, JAK2, KIT, LZTR1, MEN1, MET, MLH1, MRE11A, MSH2, MSH6, MUTYH, NF1, NF2, PALB2, PDGFRA, PMS2, POLD1, POLE, PRKAR1A, PTCH1, PTEN, PTPN11, RB1, RET, RUNX1, SDHA, SDHB, SDHC, SDHD, SF3B1, SMAD4, SMARCA4, SMARCB1, STAT3, STK11, SUFU, TERT, TET2, TP53, TSC1, TSC2, U2AF1, VHL, WT1`


### 3. Fusion Gene lists

#### 3.1 Known Fusion Pairs

Known [fusion pairs](https://github.com/umccr/workflows/blob/master/genes/fusions/knownFusionPairs.csv) provided by [Hartwig Medical Foundation](https://github.com/hartwigmedical/).

#### 3.2 Known Promiscuous Fusion Genes

Known promiscuous fusion genes ([5' list](https://github.com/umccr/workflows/blob/master/genes/fusions/knownPromiscuousFive.csv), [3' list](https://github.com/umccr/workflows/blob/master/genes/fusions/knownPromiscuousThree.csv)) provided by [Hartwig Medical Foundation](https://github.com/hartwigmedical/).

#### 3.3 FusionCatcher Known Pairs

Additional [known fusions](https://github.com/umccr/workflows/blob/master/genes/fusions/fusioncatcher_pairs.txt) from [FusionCatcher](https://github.com/ndaniel/fusioncatcher) generated from a [host of databases](https://github.com/ndaniel/fusioncatcher/blob/master/doc/manual.md#23---genomic-databases).

**Gene List Usage:**

TBA

**Questions:**

* [ ] How is https://github.com/umccr/workflows/blob/master/genes/fusions/compare.R being used?
* [ ] Where in the workflow are these fusion lists used? Provide pointers and reference; add basic intro to 3 above.  _Not_ used for bcbio's svprioritize step.
* [ ] Used anywhere in Cancer Report: (known fusion pairs?)


### 4. SAGE Hotspots

A list of genomic coordinates to rescue low AF somatic variant calls in well-known key sites of cancer genes based on:

* Cancer Genome Interpreter
* CIViC - Clinical interpretations of variants in cancer
* OncoKB - Precision Oncology Knowledge Base

**Gene List Usage:**

* SAGE: to rescue low allelic frequency somatic calls in key sites

**Todo:**

* [ ] Generate a list of genes (and ideally hotspot coordinates, protein impact) for 4

### 5. Low Quality Sites

Variants are flagged if they overlap with a list of low-quality sites / regions based on:

* GiaB (xx low?) confidence regions,
* GnomAD whole genome common variants (max population frequency > 1%),
* Low complexity regions (Heng Li's)
* LCR, low and high GC regions, self-chain and bad promoter regions (GA4GH),
* ENCODE blacklist, (xx why - we are excluding variant calls from these?)
* Segmental duplication regions (UCSC),
* UMCCR panel of normals, build from tumor-only mutect2 calls from ~200 normal samples

**Gene List Usage:**

* SAGE: (xx is this really during the SAGE step? How are low quality site annotations used (check workflow doc)?)

**Todo:**

* [ ] Add source links (hosted if needed), versions for all lists above
* [ ] Generate overlap of 5. vs 1., then add to [section below](#Cancer-Genes-with-incomplete-coverage-in-hg38)

### Cancer Genes with incomplete coverage in hg38

#### UMCCR Cancer Gene List and the Blocklist

We are not calling variants for regions contained in the [blocklist](#variant-blocklist). The following genes from the _UMCCR Cancer Gene List_ (1) overlap (completely or partially) one or more blocklist regions:

| Chromosome | Start     | Stop      | Gene   |
|:----------:|----------:|----------:|--------|
| chr3       | 36993331  | 37050918  | MLH1   |
| chr3       | 49683946  | 49689053  | MST1   |
| chr3       | 78597239  | 79767815  | ROBO1  |
| chr3       | 89107523  | 89482134  | EPHA3  |
| chr3       | 195746764 | 195812277 | MUC4   |
| chr3       | 195746764 | 195812277 | MUC4   |
| chr6       | 292096    | 351355    | DUSP22 |
| chr7       | 152134928 | 152436005 | KMT2C  |
| chr9       | 214864    | 465259    | DOCK8  |
| chr12      | 280128    | 389454    | KDM5A  |
| chr12      | 113057689 | 113098028 | DTX1   |
| chr12      | 124324414 | 124535603 | NCOR2  |
| chr18      | 47831550  | 47931146  | SMAD2  |
| chr18      | 52340171  | 53535899  | DCC    |
| chrX       | 1190489   | 1212750   | CRLF2  |
| chrX       | 1462571   | 1537107   | P2RY8  |
| chrX       | 67544035  | 67730619  | AR     |

**Todo:**

* [ ] Check for overlap between this blocklist table and the [SAGE Hotspots](#4-SAGE-Hotspots)
* [ ] Are the coordinates above gene coordinates or the blocklist overlap?

#### UMCCR Cancer Gene List and Segmental Duplications

Many of our genes of interest overlap with regions of segmental duplication (in both GRCh37 and hg38) which can [make alignment and variant calling tricky](https://blog.goldenhelix.com/why-you-should-care-about-segmental-duplications/). We rely on data from the [Segmental Duplication Database](http://humanparalogy.gs.washington.edu/) (hg38 data from <http://humanparalogy.gs.washington.edu/build38/data/>, downloaded 2019-11-05) at WashU to flag problematic genes and gene regions. Some genes - such as U2AF1 - are completely duplicated, but for the majority of our target genes the impact is limited to intronic InDels that are difficult to resolve.

The overlap between the retrieved segmental duplication regions and APPRIS cannonical transcripts (xx confirm) is [generated automatically](https://github.com/umccr/genes/blob/master/scripts/intersect_superdup.md) and results are listed on [Github](https://github.com/umccr/genes/blob/master/superdups/hg38_cod_dup.tsv). We will rely on coverage statistics generated from our panel of normal (xx Add link) to identify problematic regions in more detail but the following _UMCCR Cancer Gene List_ (1) genes may be affected:

> ABRAXAS1, ACTB, ACTG1, AFF3, ANKRD11, APOBEC3B, ARHGAP5, ARID3B, BCL2L12, BCLAF1, BCR, BMPR1A, BRAF, BRCA1, BTG1, CDC42, CDK8, CHEK2, CTNND1, CUX1, CYP2C8, CYP2D6, DCUN1D1, DICER1, DIS3L2, DNAJB1, E2F3, EIF1AX, EIF4E, EP400, FAM47C, FANCD2, FCGR2B, FEN1, FGF7, FKBP9, FLG, FLT1, FOXO3, GBA, GNAQ, GPC5, GTF2I, H3F3B, H3F3C, HIST2H3A, HIST2H3C, HIST2H3D, HLA-A, HMGA1, IGF2BP2, IL6ST, KAT7, KMT2C, KRAS, MAP2K4, MGAM, MKI67, MLLT10, MLLT6, MSN, MST1, MUC4, NBEA, NCOA4, NCOR1, NF1, NFE2L3, NOTCH2, NUTM2A, NUTM2B, PAFAH1B2, PCBP1, PDE4DIP, PDPK1, PIGA, PIK3CA, PIK3CD, PLAGL2, PMS2, POLH, PPFIBP1, PPP4R2, PRDM9, PRKCI, PRSS1, PTEN, PTP4A1, RAD21, RANBP2, RCC2, RECQL, RGPD3, RPL22, RPS6KB1, RRAS2, S100A7, SBDS, SDHA, SET, SHQ1, SIN3A, SIRPA, SMG1, SNX29, SOX2, SP140, SPECC1, SRSF3, SSX1, SSX2, SSX4, STAT5A, STAT5B, STK19, STRN, SUZ12, TAF15, TBL1XR1, TCEA1, TERF2IP, THRAP3, TOP1, TPM3, TPM4, TPMT, TRIP11, USP6, USP8, WRN, XIAP, YES1, ZNF479, ICOSLG, KMT5A, MUC1, ROBO2, U2AF1, UHRF1

#### ALT Handling

Write up chr6 issue, CLIC1 example, https://www.biorxiv.org/content/10.1101/868570v1.full.pdf, Heng Li, GATK post

https://www.ncbi.nlm.nih.gov/grc/human?filters=chr:13#current-regions

https://software.broadinstitute.org/gatk/blog?id=8180

https://github.com/lh3/bwa/blob/master/README-alt.md

> I think UK biobank forgot the .alt file so bwa-mem didn't adjust scores (which happens during mapping; step 1 in the link you posted above). We have that file in the bcbio distribution so we're all good.

**Todo:**

* [ ] Restrict overlap to APPRIS canonical transcripts to harmonize across document (if not already the case)
* [ ] Looking at IGV I am not sure that https://github.com/umccr/genes/blob/master/superdups/hg38_cod_dup.tsv is really just coding; most regions seem to be intronic? Need to grab BED file to confirm


**Todo:**

* [ ] Harmonize gene list naming in reports, add gene list versions



