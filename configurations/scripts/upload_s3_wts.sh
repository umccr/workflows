#!/usr/bin/env bash
#
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
  PROJECT=$(basename "$DIRECTORY")
  echo "$PROJECT"

  # Check if project folder exists, warn otherwise and move to next project
  aws s3 ls --profile prod s3://umccr-primary-data-prod/"$PROJECT"/ > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    echo "Project does not exist, please check manually."
  else
    for SAMPLE in "$DIRECTORY"/* ;
    do
      for TYPE in "$SAMPLE"/* ;
      do
        for TIMESTAMP in "$TYPE"/* ;
        do
          # Check if that specific sample (and timestamp) has been synched already
          echo "$TIMESTAMP"
          S3PATH="$PROJECT"/$(basename "$SAMPLE")/$(basename "$TYPE")/$(basename "$TIMESTAMP")/
          echo " $S3PATH"
          aws s3 ls --profile prod s3://umccr-primary-data-prod/"$S3PATH"

          if [[ $? -eq 0 ]]; then
            echo "  Sample has already been synched. Skipping upload. "
          else
            # Start sync and capture stdout in a log file
            echo "  Synching to $S3PATH."
            aws s3 sync --profile prod --no-progress "$TIMESTAMP" s3://umccr-primary-data-prod/"$S3PATH" 1>> s3.log
          
            # Create sentinel file for other tools to use
            echo "  Flagging completed upload."
            touch /tmp/wts_complete 
            aws s3 cp --profile prod /tmp/wts_complete s3://umccr-primary-data-prod/"$S3PATH"
          fi
        done
      done
    done
  fi

  echo
done
