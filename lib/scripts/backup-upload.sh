#!/bin/bash
BACKUP_FOLDER=$1
BUCKET_NAME=$2

syncToS3()
{
  DIRECTORY=$BACKUP_FOLDER/$1
  if [ -d "$DIRECTORY" ]; then
    aws s3 cp $DIRECTORY s3://$BUCKET_NAME/$1 --recursive
  else
    echo "$DIRECTORY doesn't exist"
  fi
}

YESTERDAY="$(date +%Y/%m/%d -d "yesterday")"
syncToS3 $YESTERDAY
syncToS3 access_logs/$YESTERDAY
YESTERDAY_MONTH="$(date +%Y/%m -d "yesterday")"
syncToS3 $YESTERDAY_MONTH/monthly_backup
syncToS3 $YESTERDAY_MONTH/weekly_backup
