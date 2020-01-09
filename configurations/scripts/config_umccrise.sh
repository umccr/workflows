# Hard-coded project directory for now; don't want this to go off the rails
for DIRECTORY in /g/data/gx8/projects/PROJECTDIR/2019*/ ;
do
  BATCH=$(basename $DIRECTORY)
  CLEANBATCH=${BATCH//./_}
  RUNDIR="$DIRECTORY"

  if [ -n "$(ls -A $RUNDIR/final)" ]; then
   echo "$BATCH ready for processing"

    if [ -f $RUNDIR/umccrised/all.done ]; then
      echo "  Already done"
    else
      echo "  Submit"
      cp -v /g/data/gx8/projects/std_workflow/run_umccrise.sh $RUNDIR
      cd $RUNDIR
      qsub run_umccrise.sh
    fi
  else
   echo "$BATCH still running"
  fi 

done