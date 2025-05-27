%md


🛡️ Compliance Alignment
Regulation |	Alignment | Strategy
----------:|-----------:|---------------
SOX / Basel II|	7-year retention| auditability
---------------------------------------------
GDPR/CCPA	Lifecycle expiration + object tagging for deletions
--------------------------------------------------------------
PCI-DSS	Encryption + versioning + access control
--------------------------------------------------------------

# Implementation Process
To implement the following 3 S3 Lifecycle Rules in AWS, you can use any of these methods:

- AWS Console (UI)

- AWS CLI

- Terraform (for infrastructure as code)

- CloudFormation (YAML/JSON templates)

# Below is a step-by-step implementation guide using:

## ✅ 1. AWS Console (UI)
Go to:
S3 > Your Bucket > Management tab > Lifecycle rules > Create lifecycle rule

🎯 Rule 1: raw/ – Transactional Data
Rule Name: RawDataRetention

Prefix filter: raw/

Transitions:

After 30 days → STANDARD_IA

After 180 days → GLACIER

Expiration:

After 2555 days (≈ 7 years)

🎯 Rule 2: processed/ – Cleansed Data
Rule Name: ProcessedDataRetention

Prefix filter: processed/

Transitions:

After 60 days → GLACIER

Expiration:

After 2555 days

🎯 Rule 3: reports/ – Business Reports
Rule Name: ReportRetention

Prefix filter: reports/

Transitions:

After 15 days → STANDARD_IA

Expiration:

After 730 days (2 years)

## ✅ 2. AWS CLI
bash
Copy
Edit
aws s3api put-bucket-lifecycle-configuration --bucket your-bucket-name --lifecycle-configuration '{
  "Rules": [
    {
      "ID": "RawDataRetention",
      "Filter": { "Prefix": "raw/" },
      "Status": "Enabled",
      "Transitions": [
        { "Days": 30, "StorageClass": "STANDARD_IA" },
        { "Days": 180, "StorageClass": "GLACIER
Here is the implementation of the S3 Lifecycle Rules for your specified retention policy (updated values):

# ✅ Lifecycle Rules Overview
Rule	Prefix	To STANDARD_IA	To GLACIER	Expire
Rule 1	raw/	After 90 days	After 365 days	After 2555 days (7 years)
Rule 2	processed/	After 30 days	After 180 days	After 730 days (2 years)
Rule 3	reports/	After 30 days	After 180 days	After 730 days (2 years)

#✅ AWS Console Method (Summary)
Go to S3 > Your Bucket > Management > Lifecycle rules.

Click Create lifecycle rule for each rule below.

Provide prefix (raw/, processed/, reports/) and configure transition/expiration.

#✅ AWS CLI Implementation
bash
Copy
Edit
aws s3api put-bucket-lifecycle-configuration --bucket your-bucket-name --lifecycle-configuration '{
  "Rules": [
    {
      "ID": "RawDataRetention",
      "Filter": { "Prefix": "raw/" },
      "Status": "Enabled",
      "Transitions": [
        { "Days": 90, "StorageClass": "STANDARD_IA" },
        { "Days": 365, "StorageClass": "GLACIER" }
      ],
      "Expiration": { "Days": 2555 }
    },
    {
      "ID": "ProcessedDataRetention",
      "Filter": { "Prefix": "processed/" },
      "Status": "Enabled",
      "Transitions": [
        { "Days": 30, "StorageClass": "STANDARD_IA" },
        { "Days": 180, "StorageClass": "GLACIER" }
      ],
      "Expiration": { "Days": 730 }
    },
    {
      "ID": "ReportsRetention",
      "Filter": { "Prefix": "reports/" },
      "Status": "Enabled",
      "Transitions": [
        { "Days": 30, "StorageClass": "STANDARD_IA" },
        { "Days": 180, "StorageClass": "GLACIER" }
      ],
      "Expiration": { "Days": 730 }
    }
  ]
}'
# ✅ Best Practices for S3 Lifecycle in Banking Context
Best Practice	Reason
Enable versioning + MFA delete	Prevent accidental deletion/modification
Use Intelligent Tiering for dynamic data	For unpredictable access patterns
Enable S3 Object Lock (Compliance mode)	For audit trails, prevent deletion for a set retention duration
Apply bucket policies for access control	Restrict access to critical audit and financial data
Enable server-side encryption (SSE-KMS)	Compliant with financial data security standards
Monitor S3 events with CloudWatch	Alert for lifecycle transitions or failures
