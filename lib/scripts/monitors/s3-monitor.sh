#!/bin/bash
BUCKET_NAME=$1
FOLDER_TO_CHECK=$(date +%Y/%m/%d -d "yesterday")

logs_backup $FOLDER_TO_CHECK
logs_backup /access_logs/$FOLDER_TO_CHECK

logs_backup() 
{
	YESTERDAY_BK="$(aws s3 ls s3://$BUCKET_NAME/$1/ | grep ".gz" | wc -l)"
	if [ "$YESTERDAY_BK" -ne "24" ]; then
		echo "Missing S3 backups for $1." | mail -s "Action Counter Monitor" ron@ftbpro.com, dor@ftbpro.com, shai@ftbpro.com
	fi				
}

