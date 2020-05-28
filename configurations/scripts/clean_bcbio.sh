# Hard-coded project directory for now; don't want this to go off the rails
for DIRECTORY in /g/data/gx8/projects/PROJECT/2020*/ ;
do
  BATCH=$(basename $DIRECTORY)
  CLEANBATCH=${BATCH//./_}

  cd $DIRECTORY/work/
  rm -v bcbio-*
  rm -vr bcbiotx/
  rm -v pbspro_*
  rm -v checkpoints_parallel/*.done
  rm -v run.sh.*
  echo '-----' >> log/bcbio-nextgen-debug.log

done
