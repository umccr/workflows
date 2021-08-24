## Summary of UMCCR genomic workflows

This repository contains workflow configuration information, driver scripts and related information used in UMCCR production workflows. Our production environment currently is a mix of primary data generation in the Illuminca Connected Analytics environment followed by secondary processing with bcbio on Gadi, a high-performance computing environment at the National Computational Infrastructure in Canberra.

The information in this repository focuses on the secondary data processing steps. Data staging from different object stores is documented in a related [Google-LIMS repository](https://github.com/umccr/google_lims). Please see the [A-Z of running samples](https://github.com/umccr/google_lims/blob/master/docs/a_z_setting_up_bcbio_run.md) to get you started.

Current UMCCR production workflows include:

* Germline and somatic [Exomes](https://github.com/umccr/workflows/blob/master/README_Exome.md)
* Germline and somatic WGS
* Somatic WTS
* ctTSO500

#### ToDo

* Add links, references where appropriate