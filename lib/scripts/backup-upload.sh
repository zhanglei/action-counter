#!/bin/bash
BACKUP_FOLDER=$1
BUCKET_NAME=$2
#FOLDER_TO_SYNC=$(date +%Y/%m/%d -d "yesterday")
#DIRECTORY=$BACKUP_FOLDER/$FOLDER_TO_SYNC

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

# if [ -d "$DIRECTORY" ]; then
#   aws s3 cp $DIRECTORY s3://$BUCKET_NAME/$FOLDER_TO_SYNC --recursive
# else
#   echo "$DIRECTORY doesn't exist"
# fi
# ACCESS_LOGS_FOLDER_TO_SYNC=$BACKUP_FOLDER/access_logs/$FOLDER_TO_SYNC
# if [ -d "$ACCESS_LOGS_FOLDER_TO_SYNC" ]; then
#   aws s3 cp $ACCESS_LOGS_FOLDER_TO_SYNC s3://$BUCKET_NAME/access_logs/$FOLDER_TO_SYNC --recursive
# else
#   echo "$ACCESS_LOGS_FOLDER_TO_SYNC doesn't exist"
# fi

