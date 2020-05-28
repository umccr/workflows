#!/bin/bash
#PBS -P gx8
#PBS -q normal
#PBS -l walltime=4:00:00
#PBS -l mem=8GB
#PBS -l ncpus=12
#PBS -l software=bcbio
#PBS -l wd
#PBS -l storage=gdata/gx8

# Merge samples and create new CSV summary
export PATH=/g/data/gx8/local/production/bin:/g/data3/gx8/local/production/bcbio/anaconda/bin:/opt/bin:/bin:/usr/bin:/opt/pbs/default/bin
#export PATH=/g/data/gx8/local/development/bin:/g/data3/gx8/local/development/bcbio/anaconda/bin:/opt/bin:/bin:/usr/bin:/opt/pbs/default/bin
#bcbio_prepare_samples.py --out merged --csv TEMPLATE.csv -n 2 -q expressbw -s pbspro -t ipython -r 'walltime=4:00:00;noselect' --retries 1 --timeout 900

bcbio_fastq_umi_prep.py autopair -c 12 *.gz
bcbio_prepare_samples.py --out merged --csv TEMPLATE.csv -n 2 -m 4 -q express -t local

# Generate the bcbio config from a standard workflow template
bcbio_vm.py template --systemconfig bcbio_system_normalgadi.yaml /g/data/gx8/projects/std_workflow/std_workflow_cancer_exome_hg38.yaml BATCH-merged.csv 

# Set up run scripts
sed "s|WORKFLOW|CONFIG-merged|" /g/data/gx8/projects/std_workflow/run_gadi.sh > CLEAN-merged/work/run.sh

# Move to parent directory to separate from input data
cp -rv CLEAN-merged/* ..
cp -rv CLEAN-merged-workflow/ ../config/
cp -rv bcbio_system_normalgadi.yaml ../config/ 
