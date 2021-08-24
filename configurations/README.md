## bcbio configuration settings and driver scripts for NCI's Gadi

* bcbio_system_normalgadi.yaml: resource configuration defining cores, memory and file paths

A number of `merge` scripts that get moved into place automatically by one of the `config_*` helpers in `scripts`:

* `merge.sh`: helper script to merge WGS T/N samples (see [docs](https://github.com/umccr/google_lims/blob/master/docs/2019-01-09_bcbio_singletons.md))
* `merge_exome.sh`: likewise for exomes (tumor/normal, Agilent CRE, UMIs)
* `merge_ffpe.sh`: WGS T/N, reduced settings to support FFPE
* `merge_germline.sh`: WGS germline only
* `merge_wts.sh`: WTS, tumor only

We also have experimental merge scripts for research projects and testing new settings:

* `merge_ffpe.dev.sh`: as above with pointers to newer bcbio versions
* `merge_GRCh37.sh`: WGS T/N vs reference GRCh37, mostly legacy purposes
* `merge_umi.sh`: Experimental support for other UMI projects

Run script to be submited to the PBSPro scheduler, again put in place automatically:

* `run_gadi.sh`: Default run script for WGS T/N
* `run_umccrise.sh`: For umccrise post-processing on Gadi (Debugging purposes only)
* `run_wts.sh`: Default runner for WTS

And finally the standard workflow desriptions. Names should be self-explanatory:

* `std_workflow_cancer_exome_hg38.yaml`
* `std_workflow_germline_exome_hg38.yaml`

* `std_workflow_cancer_hg38.yaml`
* `std_workflow_cancer_ffpe_hg38.yaml`

* `std_workflow_germline_GRCh37.yaml`
* `std_workflow_germline_hg38.yaml`
* `std_workflow_germline_hg38_umi.yaml`

* `std_workflow_wts_hg38.yaml`

Here again, `.dev.` versions exist to support the experimental workflow scripts above. Please see the `README.md` in `./scripts` for additional information on the helper scripts used to configure samples, organize for upload etc.
