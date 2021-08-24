#!/bin/bash
#PBS -P gx8
#PBS -q express
#PBS -l walltime=4:00:00
#PBS -l mem=8GB
#PBS -l ncpus=8
#PBS -l software=bcbio
#PBS -l wd
#PBS -l storage=gdata/gx8 

# Merge samples and create new CSV summary
# Note: This uses the _current_ version to support Kallisto
export PATH=/g/data3/gx8/local/development/bcbio/anaconda/bin:/g/data/gx8/local/development/bin:/opt/bin:/bin:/usr/bin:/opt/pbs/default/bin
bcbio_prepare_samples.py --out merged --csv TEMPLATE.csv -n 8 -t local

# Generate the bcbio config from a standard workflow template
bcbio_vm.py template --systemconfig bcbio_system_normalgadi.yaml /g/data/gx8/projects/std_workflow/std_workflow_wts_hg38.yaml BATCH-merged.csv 

# Set up run scripts
sed "s|WORKFLOW|CONFIG-merged|" /g/data/gx8/projects/std_workflow/run_wts.sh > CLEAN-merged/work/run.sh

# Move to parent directory to separate from input data
cp -rv CLEAN-merged/* ..
cp -rv bcbio_system_normalgadi.yaml ../config/ 
