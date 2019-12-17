# workflows

UMCCR production workflows

## Primary WGS Processing Workflow with bcbio

* bcbio intro
* link to YAML
* bcbio notes from https://app.slack.com/docs/T025SCF7W/FM38J7UHE
* Links to the exact hg38 build used; in particular explore ALT contig issue
* Explain umccr_cancer_genes.hg38.transcript.bed
* Explain umccr_cancer_genes.latest.genes

**Snippets:**


> `      exclude_regions: [altcontigs]`

Variants are being called for [chr1-22/X/Y/MT only](https://bcbio-nextgen.readthedocs.io/en/latest/contents/configuration.html#analysis-regions), i.e., limited to the standard chromosomes. We avoid [alternative and unplaced contigs](https://github.com/lh3/bwa/blob/master/README-alt.md) completely to avoid slowdowns on those additional regions.

### Variant Blocklist

> `      variant_regions: hg38_noalt_noBlacklist.bed`

We also avoid regions in the [ENCODE 'blocklist'](https://github.com/Boyle-Lab/Blacklist) [hg38-blacklist.v2.bed.gz](https://github.com/Boyle-Lab/Blacklist/tree/master/lists) of anomalous regions. This not only improves overall precision of our calls but also speeds up the variant calling process.

> hg38_noalt_noBlacklist.bed was supposed to be the result of bedtools subtract of hg38_noalt and the corresponding file in https://github.com/Boyle-Lab/Blacklist/tree/master/lists

## WGS Postprocessing with umccrise

* Move https://docs.google.com/document/d/1yBaSExF50pXk3P6Kl1SnIa_IQagD_Vu_-YOkxkHMB1Q/edit over here

## Reporting structure

* Go over standard umccrise outputs, link to current SEQC-II report samples

## Gene Lists

### 1. UMCCR Cancer Gene List

UMCCR uses a gene list ("UMCCR Cancer Gene List") to assess coverage of key genes, rescue low allelic frequency variants and to prioritize SV calls. The core list is [automatically generated](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/key_genes/make_umccr_cancer_genes.Rmd) from a number of different sources:

* Cancermine with at least 2 publications with at least 3 citations,
* NCG known cancer genes,
* Tier 1 COSMIC Cancer Gene Census (CGC),
* CACAO hotspot genes (curated from ClinVar, CiViC, cancerhotspots),
* At least 2 matches in the following five databases and eight clinical panels (xx which is which):
  * Cancer predisposition genes (CPSR list),
  * COSMIC Cancer Gene Census (tier 2),
  * AZ300, 
  * Familial Cancer, 
  * OncoKB annotated,
  * MSKC-IMPACT, 
  * MSKC-Heme, 
  * PMCC-CCP, 
  * Illumina-TS500, 
  * TEMPUS, 
  * Foundation One, 
  * Foundation Heme, 
  * Vogelstein.

Gene lists for all (xx most) of these sources can be found in the [sources](https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources/arthur) folder. The combined list contains [1250 genes](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/key_genes/umccr_cancer_genes.2019-07-31.tsv). 

All gene lists are in the process of being migrated to the [Australian PanelApp instance](https://panelapp.agha.umccr.org/); for now the latest gene list can be found in [Github](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/key_genes/umccr_cancer_genes.latest.genes). A BED file with gene and transcript coordinates is [generated from the latest gene list](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/key_genes/Snakefile) using coordinates from (xx Unclear. RefSeq version? ENSEMBL version?). 

> Also rebuild the BED files to contain only canonical transcripts (Vlad) (xx which I think results in `umccr_cancer_genes.hg38.transcript.bed` ?)

Genomic coordinates are further subset to cannonical transcripts using [APPRIS](http://appris.bioinfo.cnio.es/#/). (xx source?)

**Todo:**

* [ ] Distinguish between / clean up https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources vs https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources/arthur
* [ ] Add missing gene lists to `sources` folder (e.g., Vogelstein)
* [ ] Provide URLs, verions for all gene lists in `sources` folder; some information at https://trello.com/c/7j3KFMiL/184-umccr-cancer-genes?menu=filter&filter=member:oliverhofmann
* [ ] Need APPRIS principal transcript list somewhere (versioned, referenced in umccrise)
* [ ] Move cancer gene list code to UMCCR / workflow repos

### 2. Custom Cancer Predisposition Gene List

To assess predisposition to cancer we use CPSR's [Cancer Predisposition Genes](https://github.com/sigven/cpsr#cancer-predisposition-genes), a virtual panel based on the union of:

* 152 genes that were curated and established within TCGA’s pan-cancer study (TCGA_PANCAN_18 [Huang et al., Cell, 2018](https://www.ncbi.nlm.nih.gov/pubmed/29625052))
* 107 protein-coding genes that has been manually curated in COSMIC’s [Cancer Gene Census v90](https://cancer.sanger.ac.uk/census) (CGC_86),
* 148 protein-coding genes established by experts within the Norwegian Cancer Genomics Consortium (NCGC, <http://cancergenomics.no>)

The combination of the three sources resulted in a non-redundant set of [213 protein-coding genes](https://github.com/sigven/cpsr/blob/master/predisposition.md) of relevance for predisposition to tumor development. We are considering a switch to the more specific virtual panels from Genomics England (see [panels 1-38](https://github.com/sigven/cpsr#cancer-predisposition-genes)) in the future. 

**Todo:**

* [ ] Version predisposition gene list (via PanelApp if possible)
* [ ] Explore adding PMCC Mol Path germline list

### 3. Fusion Gene lists

#### 3.1 Known Fusion Pairs

Known [fusion pairs](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/fusions/knownFusionPairs.csv) provided by [Hartwig Medical Foundation](https://github.com/hartwigmedical/).

#### 3.2 Known Promiscuous Fusion Genes

Known promiscuous fusion genes ([5' list](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/fusions/knownPromiscuousFive.csv), [3' list](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/fusions/knownPromiscuousThree.csv)) provided by [Hartwig Medical Foundation](https://github.com/hartwigmedical/).

#### 3.3 FusionCatcher Known Pairs

Additional known fusions from FusionCatcher generated from a [host of databases](https://github.com/ndaniel/fusioncatcher/blob/master/doc/manual.md#23---genomic-databases).

(xx Needs a link or we need to host the currently used known pair set.)

* [ ] Provide sources for all fusion lists. One source is https://nc.hartwigmedicalfoundation.nl/index.php/s/a8lgLsUrZI5gndd?path=%2FHMFTools-Resources%2FLINX but it's not stable and there seems to be no way to retrieve older lists
* [ ] Version fusion lists
* [ ] Move to UMCCR / workflow repo

### 4. SAGE Hotspots

A list of genomic coordinates to rescue low AF somatic variant calls in well-known key sites of cancer genes based on:

* Cancer Genome Interpreter 
* CIViC - Clinical interpretations of variants in cancer
* OncoKB - Precision Oncology Knowledge Base

**Todo:**

* [ ] Generate a list of genes (and ideally hotspot coordinates, protein impact) for 4.1 

### 5. Low Quality Sites

Variants are flagged if they overlap with a list of low-quality sites / regions based on:

* GiaB (xx low?) confidence regions,
* GnomAD whole genome common variants (max population frequency > 1%),
* Low complexity regions (Heng Li's)
* LCR, low and high GC regions, self-chain and bad promoter regions (GA4GH),
* ENCODE blacklist, (xx why - we are excluding variant calls from these?)
* Segmental duplication regions (UCSC),
* UMCCR panel of normals, build from tumor-only mutect2 calls from ~200 normal samples

**Todo:**

* [ ] Add source links (hosted if needed), versions for all lists above
* [ ] Generate overlap of 5. vs 1., then add to [section below](#Cancer-Genes-with-incomplete-coverage-in-hg38)

### Gene List Usage

* bcbio SV prioritization: `umccr_cancer_genes.latest.genes` (xx Clarify interaction with umccrise)
* MultiQC: _UMCCR Cancer Gene List_ (1) for coverage assessment (General Statistics table) (xx canonical transcripts only?)
* CPSR: _Custom Cancer Predisposition Gene List_ (2) for tier assessment
* Cancer Report: _UMCCR Cancer Gene List_ (1) (xx for which tables, sets?)
* Cancer Report: CDS of _UMCCR Cancer Gene List_ (1) for SNV Allelic Frequencies in Key Genes CDS
* Cancer Report: _UMCCR Cancer Gene List_ (1) for UMCCR Gene CNV Calls table
* Cancer Report: (xx known fusion pairs?)
* SAGE: _SAGE Hotspots_ (4) to rescue low allelic frequency somatic calls in key sites
* SAGE: _Low Quality Sites_ (5) (xx is this really during the SAGE step? How are low quality site annotations used (check workflow doc)?)

**Todo:**

* [ ] Confirm coverage is based on `umccr_cancer_genes.hg38.transcript.bed`
* [ ] Clarify bcbio's `svprioritize` vs umccrise handling
* [ ] Where are we using 3.1 - 3.3 precisely? _Not_ used for bcbio's svprioritize step
* [ ] Cancer Report: Structural Variants table references oncogene, tsgene annotation. From which gene list is this coming from?
* [ ] Harmonize gene list naming in reports, add gene list versions
* [ ] Check for overlap with [Hartwig key gene list](https://nc.hartwigmedicalfoundation.nl/index.php/s/a8lgLsUrZI5gndd?path=%2FPatient-Reporting)

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

* [ ] Check for overlap between this blocklist table and the [SAGE Hotspots](#4.-SAGE-Hotspots)

#### UMCCR Cancer Gene List and Segmental Duplications

Many of our genes of interest overlap with regions of segmental duplication (in both GRCh37 and hg38) which can [make alignment and variant calling tricky](https://blog.goldenhelix.com/why-you-should-care-about-segmental-duplications/). We rely on data from the [Segmental Duplication Database](http://humanparalogy.gs.washington.edu/) (hg38 data from <http://humanparalogy.gs.washington.edu/build38/data/>, downloaded 2019-11-05) at WashU to flag problematic genes and gene regions. Some genes - such as U2AF1 - are completely duplicated, but for the majority of our target genes the impact is limited to intronic InDels that are difficult to resolve.

The overlap between the retrieved segmental duplication regions and APPRIS cannonical transcripts (xx confirm) is [generated automatically](https://github.com/umccr/genes/blob/master/scripts/intersect_superdup.md) and results are listed on [Github](https://github.com/umccr/genes/blob/master/superdups/hg38_cod_dup.tsv). We will rely on coverage statistics generated from our panel of normal (xx Add link) to identify problematic regions in more detail but the following _UMCCR Cancer Gene List_ (1) genes may be affected:

```
ABRAXAS1, ACTB, ACTG1, AFF3, ANKRD11, APOBEC3B, ARHGAP5, ARID3B, BCL2L12, BCLAF1, BCR, BMPR1A, BRAF, BRCA1, BTG1, CDC42, CDK8, CHEK2, CTNND1, CUX1, CYP2C8, CYP2D6, DCUN1D1, DICER1, DIS3L2, DNAJB1, E2F3, EIF1AX, EIF4E, EP400, FAM47C, FANCD2, FCGR2B, FEN1, FGF7, FKBP9, FLG, FLT1, FOXO3, GBA, GNAQ, GPC5, GTF2I, H3F3B, H3F3C, HIST2H3A, HIST2H3C, HIST2H3D, HLA-A, HMGA1, IGF2BP2, IL6ST, KAT7, KMT2C, KRAS, MAP2K4, MGAM, MKI67, MLLT10, MLLT6, MSN, MST1, MUC4, NBEA, NCOA4, NCOR1, NF1, NFE2L3, NOTCH2, NUTM2A, NUTM2B, PAFAH1B2, PCBP1, PDE4DIP, PDPK1, PIGA, PIK3CA, PIK3CD, PLAGL2, PMS2, POLH, PPFIBP1, PPP4R2, PRDM9, PRKCI, PRSS1, PTEN, PTP4A1, RAD21, RANBP2, RCC2, RECQL, RGPD3, RPL22, RPS6KB1, RRAS2, S100A7, SBDS, SDHA, SET, SHQ1, SIN3A, SIRPA, SMG1, SNX29, SOX2, SP140, SPECC1, SRSF3, SSX1, SSX2, SSX4, STAT5A, STAT5B, STK19, STRN, SUZ12, TAF15, TBL1XR1, TCEA1, TERF2IP, THRAP3, TOP1, TPM3, TPM4, TPMT, TRIP11, USP6, USP8, WRN, XIAP, YES1, ZNF479, ICOSLG, KMT5A, MUC1, ROBO2, U2AF1, UHRF1
```

**Todo:**

* [ ] Restrict overlap to APPRIS canonical transcripts to harmonize across document (if not already the case)
* [ ] Looking at IGV I am not sure that https://github.com/umccr/genes/blob/master/superdups/hg38_cod_dup.tsv is really just coding; most regions seem to be intronic? Need to grab BED file to confirm


## ToDo

* Add info from https://trello.com/c/suFTZWRF/420-workflow-test-cancer-gene-list-overlap-with-blacklist

