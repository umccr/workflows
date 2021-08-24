#!/bin/bash
#PBS -P gx8
#PBS -q normal
#PBS -l walltime=12:00:00
#PBS -l mem=2GB
#PBS -l ncpus=1
#PBS -l software=umccrise
#PBS -l wd
#PBS -l storage=gdata/gx8
export PATH=/opt/bin:/bin:/usr/bin:/opt/pbs/default/bin

# Dev version
#source /g/data3/gx8/extras/umccrise_2019_Nov/load_umccrise.sh

# Alpha version
#source /g/data/gx8/extras/umccrise_017_2020_Jan/load_umccrise.sh

# Production version
source /g/data/gx8/extras/umccrise/load_umccrise.sh
umccrise . -j 16 --cluster-auto --unlock
