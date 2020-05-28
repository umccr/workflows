# Iterate over projects in s3 folder and upload to S3 bucket
#
# Expects data to be organized data according to
#
#  Project -> Subject -> Type -> Timestamp
#
# in a `s3` folder ready to be archived on AWS in the relevant
# `project` folder.
for DIRECTORY in /g/data/gx8/projects/PROJECT/s3/* ;
do
  PROJECT=$(basename $DIRECTORY)
  echo $PROJECT

  # Check if project folder exists, warn otherwise and move to next project
  aws s3 ls s3://umccr-primary-data-prod/$PROJECT/ > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    echo "Project does not exist, please check manually."
  else
    for SUBJECT in $DIRECTORY/* ;
    do
      for TYPE in $SUBJECT/* ;
      do
        for TIMESTAMP in $TYPE/* ;
        do
          # Check if that specific subject (and timestamp) has been synched already
          echo $TIMESTAMP
          S3PATH=$PROJECT/$(basename $SUBJECT)/$(basename $TYPE)/$(basename $TIMESTAMP)
          echo " $S3PATH"
          aws s3 ls s3://umccr-primary-data-prod/$S3PATH/

          if [[ $? -eq 0 ]]; then
            echo "  Subject has already been synched. Skipping upload. "
          else
            # Start sync and capture stdout in a log file
            echo "  Synching to $S3PATH"
            aws s3 sync --no-progress $TIMESTAMP s3://umccr-primary-data-prod/$S3PATH/ 1>> s3.log

            # Create sentinel file to flag upload has completed
            echo "  Upload complete"
            touch /tmp/upload_complete 
            aws s3 cp /tmp/upload_complete s3://umccr-primary-data-prod/$S3PATH/upload_complete
          fi

          # Test for umccrise flag that signals post-processing was done
          aws s3 ls s3://umccr-primary-data-prod/$S3PATH/umccrised/all.done          

          if [[ $? -eq 0 ]]; then
            echo '  Post-processing has finished for subject.'
          else
            # API call to start umccrise for uploaded sample
            echo "  Starting umccrise"
            aws lambda invoke --function-name umccrise_lambda_prod --cli-binary-format raw-in-base64-out --payload '{ "inputDir": "'$S3PATH'", "vcpus": "16", "inputBucket" : "umccr-primary-data-prod"}' /tmp/lambda.output
          fi
        done
      echo "* Synced $SUBJECT to s3://umccr-primary-data-prod/$S3PATH/"
      echo "----"
      done
    done
  fi

  echo
done
