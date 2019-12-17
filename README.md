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

Variants are being called for chr1-22/X/Y/MT only, i.e., limited to the standard chromosomes. We avoid [alternative and unplaced contigs](https://github.com/lh3/bwa/blob/master/README-alt.md) completely to avoid slowdowns on those additional regions.

> `      variant_regions: hg38_noalt_noBlacklist.bed`

We also avoid regions in the [ENCODE 'blocklist'](https://github.com/Boyle-Lab/Blacklist) [hg38-blacklist.v2.bed.gz](https://github.com/Boyle-Lab/Blacklist/tree/master/lists) of anomalous regions. This not only improves overall precision of our calls but also speeds up the variant calling process.

> hg38_noalt_noBlacklist.bed was supposed to be the result of bedtools subtract of hg38_noalt and the corresponding file in https://github.com/Boyle-Lab/Blacklist/tree/master/lists

## WGS Postprocessing with umccrise

* Move https://docs.google.com/document/d/1yBaSExF50pXk3P6Kl1SnIa_IQagD_Vu_-YOkxkHMB1Q/edit over here

## Reporting structure

* Go over standard umccrise outputs, link to current SEQC-II report samples

## Gene Lists

### UMCCR Cancer Gene List

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

Gene lists for all (xx most) of these can be found in the [sources](https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources/arthur) folder.

The result is a list of 1248 genes. All gene lists are in the process of being migrated to the [Australian PanelApp instance](https://panelapp.agha.umccr.org/); for now the latest gene list can be found in [Github](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/key_genes/umccr_cancer_genes.latest.genes). A BED file with gene and transcript coordinates is [generated from the latest gene list](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/key_genes/Snakefile) using coordinates from (xx Unclear. RefSeq version? ENSEMBL version?). 

**Todo:**

* [ ] Distinguish between / clean up https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources vs https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources/arthur
* [ ] Add missing gene lists to `sources` folder (e.g., Vogelstein)
* [ ] Provide URLs, verions for all gene lists in `sources` folder
* [ ] Move cancer gene list code to UMCCR / workflow repos


* List all current gene panels used throughout the workflows
* Document / links to https://github.com/vladsaveliev/NGS_Utils/tree/master/ngs_utils/reference_data/key_genes/sources
* See https://trello.com/c/ZN52jqqs/421-workflow-add-gene-lists-to-panelapp





### Cancer Genes with incomplete coverage in hg38

* Document https://trello.com/c/6nTsNLnZ/461-debug-mapq0-issues
* Add info from https://trello.com/c/suFTZWRF/420-workflow-test-cancer-gene-list-overlap-with-blacklist

