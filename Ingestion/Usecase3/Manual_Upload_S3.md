%md

# ✅ Use Case 3: Manual Upload of Reference Data to S3 by Business Users
🎯 Goal
Allow authorized business/data users to manually upload reference data (e.g., branch codes, currency info, product mappings) to specific S3 buckets/folders, securely and in a controlled manner.

📐 Architecture
css
Copy
Edit
Business User
     │
     ▼
[Secure Auth]
     │
     ▼
┌──────────────────────────────┐
│  S3 Bucket (ref-data-zone)   │
│ └─ /product_mapping/         │
│ └─ /currency_codes/          │
└──────────────────────────────┘
     │
     ▼
[Crawler + Catalog] ───> [Athena]

## 🛠️ Implementation Steps
1. 🔐 IAM User or Role-Based Access
Create IAM users or federated roles for business users.

Example IAM Policy (Least Privilege)
json
Copy
Edit
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificUpload",
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::ref-data-zone",
        "arn:aws:s3:::ref-data-zone/product_mapping/*"
      ]
    }
  ]
}
✅ Use prefixes (product_mapping/, currency_codes/) to restrict folders.

## 2. 🧾 Upload Methods for Users
Give business users these options:

AWS Console (UI)
Users log in with IAM credentials and upload CSVs using the S3 web interface.

AWS CLI
Example:

bash
Copy
Edit
aws s3 cp product_mapping.csv s3://ref-data-zone/product_mapping/
AWS Transfer Family (Optional)
For SFTP-based uploads if your users are non-technical.

## 3. 📊 Trigger Crawlers
Run AWS Glue Crawlers on a schedule or post-upload to:

Detect new files

Infer schema

Update AWS Glue Catalog

Example Glue Crawler Settings:

Include path: s3://ref-data-zone/product_mapping/

File type: CSV

Update behavior: "Update existing schema"

## 4. 📈 Query Uploaded Data Using Athena
Once crawled, business users or analysts can run SQL queries on the uploaded reference data.

sql
Copy
Edit
SELECT * 
FROM ref_data_db.product_mapping
WHERE product_type = 'Savings';
## 5. 🛡️ Optional Governance & Validation
Use AWS Lambda + S3 Trigger to validate format/schema on upload.

Example: Reject non-CSV files or bad headers.

Use S3 Event Notifications to log/alert on changes.

📦 Folder Structure Suggestion
pgsql
Copy
Edit
s3://ref-data-zone/
  └─ product_mapping/
       └─ product_mapping_2025-05-27.csv
  └─ currency_codes/
       └─ currency_2025-05-27.csv
✅ Benefits
Feature	Description
Self-service	Empowers business users to manage data
Secure	IAM permissions, folder-level access
Queryable	Glue + Athena integration
Scalable	Supports CSV, JSON, Parquet, etc.
