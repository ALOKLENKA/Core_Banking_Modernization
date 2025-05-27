%md

Here’s an implementation for Use Case 1 from your project:

# UseCase 1: Upstream system pushes data to an S3 bucket via Unix, using a flag file mechanism. When a zero-byte flag file appears in the landing zone, Autosys triggers a Unix shell script that uses AWS CLI to copy the data to the final S3 location.

📁 Folder Structure (S3 Landing & Target)
- /landing/ – Initial bucket folder where files are dropped by upstream

- /processed/ – Target bucket folder after successful upload

- /flag/ – Zero-byte file indicating data is ready for upload

### 🧾 1. Autosys Job (conceptual)
You'd define a File Watcher job in Autosys:

% autosys

insert_job: check_flag_file  job_type: f
machine: unix_server
watch_file: /data/landing/trigger_file.flag
watch_interval: 60
command: /scripts/upload_to_s3.sh

### 🖥️ 2. Unix Shell Script – upload_to_s3.sh
%bash

#!/bin/bash

#### Variables
LANDING_DIR="/data/landing"
S3_BUCKET="s3://your-bucket-name/processed"
LOG_FILE="/logs/s3_upload.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "$DATE - Script started" >> $LOG_FILE

#### Check for flag file
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

### ✅ Pre-Requisites
- aws configure done on Unix host with access to the bucket.

- Proper IAM role or access key in .aws/credentials.

- Autosys job scheduled or triggered with appropriate intervals.
