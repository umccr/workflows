## Helper scripts for NCI's Gadi

Almost all sripts require a single manual configuration: replacing the `PROJECTDIR` at the top with the sample project dir to be processed. See the [docs](https://github.com/umccr/google_lims/blob/master/docs/a_z_setting_up_bcbio_run.md) for additional pointers:

* `clean_bcbio.sh`: clean up intermediate files, useful before a restart
* `config_bcbio.sh`: standard script to configure a set of single WGS T/N samples
* `config_bcbio_ffpe.sh`: for WGS/TN FFPE samples only (reduced caller set)
* `config_bcbio_germline.sh`: for germline WGS samples
* `config_bcbio_wts.sh`: for WTS samples
* `config_umccrise.sh`: to configure (and run) umccrise on sample folders with bcbio-generated results
* `draw_fusions_hg38.sh`: post-processing script for WTS results (run interactively)
* `organize_hpc.sh`: organize results and reports in new folders for easy of parsing (debugging only)
* `organize_s3.sh`: organize WGS/WTS data for submission to S3; resulting data still needs to be organized into project folders matching `s3://umccr-primary-data-prod`
* `upload_s3.sh`: upload the (now organized) WGS data from the local S3 folder to `s3://umccr-primary-data-prod` and kick off post-processing workflow (umccrise)
* `upload_s3_wts.sh`: same for WTS
