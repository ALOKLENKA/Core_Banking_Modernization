# Use Case 15: Sending Reports to Downstream On-Premises Applications from S3
This use case involves transferring the reports (CSV/JSON) that were written to Amazon S3 in Use Case 14 to on-premises systems for further use, such as archival, analytics, or regulatory reporting.

🏗️ Architecture Overview
java
Copy
Edit
AWS S3 (processed/reports/)
      ↓
AWS Transfer Options (AWS DataSync / S3 SDK / CLI)
      ↓
Secure Network Connectivity (VPN / Direct Connect)
      ↓
On-Prem Server (Linux/Unix/Windows)
🛠️ Implementation Options
Option 1: ✅ Using AWS DataSync (Recommended)
Best for automated, scalable, secure sync between S3 and on-prem storage.

🔧 Prerequisites:
Configure AWS DataSync Agent on your on-premises VM or server.

Ensure VPN/Direct Connect is set up between AWS and on-prem.

Ensure IAM roles allow access to the source S3 bucket.

📝 Steps:
Create a DataSync Task

Source: Amazon S3

Destination: On-premises NFS/SMB server

Configure Include Filters (Optional)

bash
Copy
Edit
s3://your-bucket/processed/reports/transactions/csv/
Enable scheduling or run ad-hoc

bash
Copy
Edit
aws datasync start-task-execution --task-arn arn:aws:datasync:...
Option 2: ✅ Using AWS CLI + Autosys on On-Prem
Best for simple use cases with file watcher jobs.

📝 Sample Script (get_reports.sh):
bash
Copy
Edit
#!/bin/bash

S3_PATH="s3://your-bucket/processed/reports/"
LOCAL_PATH="/data/reports/"

# Download CSV and JSON files
aws s3 cp "$S3_PATH" "$LOCAL_PATH" --recursive --exclude "*" --include "*.csv" --include "*.json"

# Optional: Log success/failure
if [ $? -eq 0 ]; then
  echo "Reports downloaded successfully at $(date)" >> /var/log/report_transfer.log
else
  echo "Report download failed at $(date)" >> /var/log/report_transfer.log
fi
🕒 Schedule via Autosys JIL
jil
Copy
Edit
insert_job: report_download
job_type: c
command: /opt/scripts/get_reports.sh
machine: your_on_prem_server
owner: dataops
start_times: "08:00"
description: "Download AWS S3 reports to on-prem storage"
Option 3: ✅ Custom Integration Using Python Script
Best when needing control, logging, or retry logic.

python
Copy
Edit
import boto3
import os

s3 = boto3.client('s3')
bucket = "your-bucket"
prefix = "processed/reports/transactions/"
local_dir = "/data/reports/"

paginator = s3.get_paginator('list_objects_v2')
for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
    for obj in page.get('Contents', []):
        key = obj['Key']
        file_name = os.path.basename(key)
        local_file_path = os.path.join(local_dir, file_name)

        s3.download_file(bucket, key, local_file_path)
        print(f"Downloaded: {key} → {local_file_path}")
Schedule this with cron, Airflow, or Glue Workflow (if reverse pushing from cloud).

🔐 Security Best Practices
Area	Recommendation
IAM	Use minimal-permission roles to access S3
Network Security	Use VPN or Direct Connect to secure traffic
Logging	Enable logs on download jobs (CloudWatch or local logs)
Encryption	Encrypt data at rest (S3 SSE-KMS) and in transit (HTTPS/VPN)
Audit Trail	Use CloudTrail + S3 Access Logs for monitoring

📦 File Structure on On-Prem (Sample)
pgsql
Copy
Edit
/data/reports/
    ├── transactions/
    │   ├── 2025-05/
    │   │   ├── report.csv
    │   │   └── report.json
    └── logs/
        └── report_transfer.log
