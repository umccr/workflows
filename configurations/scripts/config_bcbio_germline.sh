#!/usr/bin/env bash                                                                                                                                                                                                                        
#                                                                                                                                                                                                                                          
# Hard-coded project directory for now; don't want this to go off the rails                                                                                                                                                                #
for DIRECTORY in /g/data/gx8/projects/PROJECT/2020*/ ;
do
  BATCH=$(basename "$DIRECTORY")
  DATADIR="$DIRECTORY"data  
  SAMPLES="$DIRECTORY"data/$BATCH

  # Copy and replace-in-place (rather than one step replace) for more flexibility
  cp -v /g/data/gx8/projects/std_workflow/merge_germline.sh "$DATADIR"/merge.sh
  cp -v /g/data/gx8/projects/std_workflow/bcbio_system_normalgadi.yaml "$DATADIR"

  sed -i "s|TEMPLATE|$SAMPLES|g" "$DATADIR"/merge.sh

  # bcbio replaces `.` in CSV templates with a `_` when creating directories
  CLEANBATCH=${BATCH//./_}
  CLEAN="$DIRECTORY"data/$CLEANBATCH

  sed -i "s|CLEAN|$CLEAN|g" "$DATADIR"/merge.sh
  sed -i "s|BATCH|$BATCH|g" "$DATADIR"/merge.sh
  sed -i "s|CONFIG|$CLEANBATCH|g" "$DATADIR"/merge.sh

  # Have the systemconfig point at the sample directory
  sed -i "s|INPUTDIR|$DATADIR/merged/|g" "$DATADIR"/bcbio_system_normalgadi.yaml

  cd "$DATADIR" || exit
  qsub merge.sh
done
