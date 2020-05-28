# Hard-coded project directory for now; don't want this to go off the rails
for DIRECTORY in /g/data/gx8/projects/PROJECT/2020*/ ;
do
  BATCH=$(basename $DIRECTORY)
  CLEANBATCH=${BATCH//./_}
  RUNDIR="$DIRECTORY"

  if [ -n "$(ls -A $RUNDIR/final)" ]; then
    # This means we're ready to sync the data to Spartan | S3
    # Organize by patient identifier
    echo "$BATCH ready for uploading to S3"
    PATIENT=$(echo $BATCH | cut -d '_' -f 4-)
    TYPE=$(echo $BATCH | cut -d '_' -f 3)

    # Add a timestamp
    TIMESTAMP=$(date +%Y-%m-%d)
    mkdir -p s3/$PATIENT/$TYPE/$TIMESTAMP/

    # Config, final directory results only
    # Copy instead of moving so we can re-run if needed
    cp -al $RUNDIR/config s3/$PATIENT/$TYPE/$TIMESTAMP/
    cp -al $RUNDIR/final s3/$PATIENT/$TYPE/$TIMESTAMP/
  else
    echo "$BATCH still running"
  fi 

done
