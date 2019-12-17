# workflows

UMCCR production workflows

## Primary WGS Processing Workflow with bcbio

* bcbio intro
* link to YAML
* bcbio notes from https://app.slack.com/docs/T025SCF7W/FM38J7UHE
* Links to the exact hg38 build used
* Explain umccr_cancer_genes.hg38.transcript.bed
* Explain umccr_cancer_genes.latest.genes

**Snippets:**


> `      exclude_regions: [altcontigs]`

Variants are being called for [chr1-22/X/Y/MT only](https://bcbio-nextgen.readthedocs.io/en/latest/contents/configuration.html#analysis-regions), i.e., limited to the standard chromosomes. We avoid [alternative and unplaced contigs](https://github.com/lh3/bwa/blob/master/README-alt.md) completely to avoid slowdowns on those additional regions.

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

> Also rebuild the BED files to contain only canonical transcripts (Vlad) (which I think results in `umccr_cancer_genes.hg38.transcript.bed`)

**Todo:**

* [ ] Distinguish between / clean up https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources vs https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources/arthur
* [ ] Add missing gene lists to `sources` folder (e.g., Vogelstein)
* [ ] Provide URLs, verions for all gene lists in `sources` folder; some information at https://trello.com/c/7j3KFMiL/184-umccr-cancer-genes?menu=filter&filter=member:oliverhofmann
* [ ] Move cancer gene list code to UMCCR / workflow repos

### 2. Custom Cancer Predisposition Gene List

To assess predisposition to cancer we use CPSR's [Cancer Predisposition Genes](https://github.com/sigven/cpsr#cancer-predisposition-genes), a virtual panel based on the union of:

* 152 genes that were curated and established within TCGA’s pan-cancer study ([TCGA_PANCAN_18, Huang et al., Cell, 2018](https://www.ncbi.nlm.nih.gov/pubmed/29625052))
* 107 protein-coding genes that has been manually curated in COSMIC’s [CGC_86, Cancer Gene Census v90](https://cancer.sanger.ac.uk/census),
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

* [ ] Provide sources for all fusion lists
* [ ] Version fusion lists
* [ ] Move to UMCCR / workflow repo

### 4. 

### 5. 

### Gene List Usage

* bcbio SV prioritization: `umccr_cancer_genes.latest.genes` (xx Clarify interaction with umccrise)
* MultiQC: "1. UMCCR Cancer Gene List" for coverage assessment (General Statistics table) (xx canonical transcripts only?)
* CPSR: "2. Custom Cancer Predisposition Gene List" for tier assessment
* Cancer Report: "1. UMCCR Cancer Gene List" (xx for which tables, sets?)
* Cancer Report: CDS of "1. UMCCR Cancer Gene List" for SNV Allelic Frequencies in Key Genes CDS
* Cancer Report: "1. UMCCR Cancer Gene List" for UMCCR Gene CNV Calls table

Cancer Report: known fusion pairs

**Todo:**

* [ ] Confirm coverage is based on `umccr_cancer_genes.hg38.transcript.bed`
* [ ] Clarify bcbio's `svprioritize` vs umccrise handling
* [ ] Where are we using 3.1 - 3.3 precisely? _Not_ used for bcbio's svprioritize step

Cancer Report: Structural variants references oncogene, tsgene annotation. Source of that gene list (or source of the annotation for the gene list if identical to the ones above)?

Cancer Report: Annotations are subset vs APPRIS (see https://docs.google.com/document/d/1yBaSExF50pXk3P6Kl1SnIa_IQagD_Vu_-YOkxkHMB1Q/edit#bookmark=id.fze4hyo5pnhg). Need the principal transcript list somewhere searchable and pinned to the current umccrise version 

SAGE: targets a list of coding regions and known hotspots outlined above (see https://docs.google.com/document/d/1yBaSExF50pXk3P6Kl1SnIa_IQagD_Vu_-YOkxkHMB1Q/edit#bookmark=id.vjse6x9bo39c). Generate a list of genes (and ideally hotspots). 

SAGE: low quality sites are flagged (see https://docs.google.com/document/d/1yBaSExF50pXk3P6Kl1SnIa_IQagD_Vu_-YOkxkHMB1Q/edit#bookmark=id.od59cxu28mr9). Need overlap of this list against our own cancer gene lists from above - at least vs the UMCCR genes.



* [ ] List all current gene panels used throughout the workflows
* [ ] Document / links to https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources
* [ ] See https://trello.com/c/ZN52jqqs/421-workflow-add-gene-lists-to-panelapp
* [ ] See https://trello.com/c/JOBhtZIE/374-workflow-unify-gene-list-information
* [ ] Harmonize gene list naming in reports




### Cancer Genes with incomplete coverage in hg38

* Document https://trello.com/c/6nTsNLnZ/461-debug-mapq0-issues
* Add info from https://trello.com/c/suFTZWRF/420-workflow-test-cancer-gene-list-overlap-with-blacklist

