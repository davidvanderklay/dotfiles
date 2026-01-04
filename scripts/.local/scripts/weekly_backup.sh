#!/bin/bash

# 1. Add the trailing slash to the source
SOURCE="/sambashare/"
DEST="van@100.108.108.93:/home/van/sambashare/"
LOGFILE="/home/van/backup_log.log"

# 2. SAFETY CHECK: Only run if the source directory is not empty
# This prevents deleting your backup if the drive isn't mounted.
if [ -z "$(ls -A $SOURCE)" ]; then
  echo "ERROR: Source directory is empty. Is the drive mounted? Aborting." >>$LOGFILE
  exit 1
fi

echo "--- Backup started at $(date) ---" >>$LOGFILE

# 3. Add --dry-run first to test safely!
# REMOVE the "-n" once you are 100% sure the log looks correct.
rsync -avz -n --delete $SOURCE $DEST >>$LOGFILE 2>&1

echo "--- Backup finished at $(date) ---" >>$LOGFILE
