# Hard-coded project directory for now; don't want this to go off the rails
#
# Organises data according to
#
#   Subject -> Type -> Timestamp
#
# in a `sync` folder ready to be archived on AWS in the relevant
# `project` folder.
#
# Also creates a convenience `reports` folder for Trello
for DIRECTORY in /g/data/gx8/projects/PROJECT/2020*/ ;
do
  BATCH=$(basename $DIRECTORY)
  CLEANBATCH=${BATCH//./_}
  RUNDIR="$DIRECTORY"

  # Test if umccrise was started
  if [ -d $RUNDIR/umccrised ]; then
    echo $RUNDIR
    # Test if umccrise _finished_
    if [ -f $RUNDIR/umccrised/all.done ]; then
      # This means we're ready to sync the data to Spartan | S3
      # Organize by patient identifier
      PATIENT=$(echo $BATCH | cut -d '_' -f 4-)
      TYPE=$(echo $BATCH | cut -d '_' -f 3)

      # Add a timestamp
      TIMESTAMP=$(date +%Y-%m-%d)
      mkdir -p sync/$PATIENT/$TYPE/$TIMESTAMP/

      # Config, final directory and umccrise results only
      # Leave a copy of the config behind in case of reruns
      cp -al $RUNDIR/umccrised sync/$PATIENT/$TYPE/$TIMESTAMP/
      cp -al $RUNDIR/config sync/$PATIENT/$TYPE/$TIMESTAMP/
      cp -al $RUNDIR/final sync/$PATIENT/$TYPE/$TIMESTAMP/

      # Extra copy to make sync to desktops easier: just the reports
      mkdir -p reports/$PATIENT
      cp -al $PWD/sync/$PATIENT/$TYPE/$TIMESTAMP/umccrised reports/$PATIENT/

      echo "  Ready for sync"
    else
      echo "  Still running"
    fi
  fi
done
