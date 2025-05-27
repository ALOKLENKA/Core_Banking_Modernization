#!/bin/bash

# Variables
LANDING_DIR="/data/landing"
S3_BUCKET="s3://your-bucket-name/processed"
LOG_FILE="/logs/s3_upload.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "$DATE - Script started" >> $LOG_FILE

# Check for flag file
if [ -f "$LANDING_DIR/trigger_file.flag" ]; then
    echo "$DATE - Flag file found. Proceeding to upload..." >> $LOG_FILE

    # Loop through all data files (excluding flag file)
    for file in "$LANDING_DIR"/*; do
        fname=$(basename "$file")
        if [[ "$fname" != "trigger_file.flag" ]]; then
            echo "$DATE - Uploading $fname to S3" >> $LOG_FILE
            aws s3 cp "$file" "$S3_BUCKET/$fname" --only-show-errors

            if [ $? -eq 0 ]; then
                echo "$DATE - Successfully uploaded $fname" >> $LOG_FILE
                rm -f "$file"
            else
                echo "$DATE - Failed to upload $fname" >> $LOG_FILE
            fi
        fi
    done

    # Delete the flag file after successful transfer
    echo "$DATE - Removing flag file" >> $LOG_FILE
    rm -f "$LANDING_DIR/trigger_file.flag"
else
    echo "$DATE - Flag file not found. Exiting." >> $LOG_FILE
    exit 0
fi

echo "$DATE - Script completed" >> $LOG_FILE
