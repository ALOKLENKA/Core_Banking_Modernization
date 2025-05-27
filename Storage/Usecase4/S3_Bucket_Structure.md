# ✅ Use Case 4: S3 Data Lake – Store Raw Data as the Single Source of Truth
## 🎯 Objective
Create a centralized raw data repository on Amazon S3 that acts as the single source of truth across all data domains. This includes data ingested from:

Upstream systems (via push)

Oracle DB (via GoldenGate)

Manual uploads by users (Use Case 3)

All raw data is preserved unaltered, versioned, and encrypted.

## 🧱 Architecture
scss
Copy
Edit
                ┌───────────────┐
                │  Upstream     │
                │  Systems      │
                └────┬──────────┘
                     ▼
            ┌────────────────────┐
            │   S3 Data Lake     │
            │  (Raw Zone)        │
            └────┬───────────────┘
                 ▼
      ┌────────────────────────────┐
      │ Crawler + Glue Catalog     │
      └────┬───────────────────────┘
           ▼
        [Athena Queries]
## 📁 Folder Structure (Recommended)
sql
Copy
Edit
s3://org-datalake-raw/
├── transactions/
│   ├── year=2025/
│   │   └── month=05/
│   │       └── day=27/
│   │           └── transaction_20250527.csv
├── customer_master/
│   └── uploaded_on=2025-05-27/
│       └── customer_20250527.csv
├── branch_codes/
│   └── uploaded_on=2025-05-27/
Use partitioned folder structures to enable efficient querying.

## 🛠️ Key Implementation Steps
1. ✅ Create a Secure S3 Bucket
Configure bucket with:

Encryption (AES-256 or KMS)

Versioning (to preserve past data)

Lifecycle Policy (if needed, for archival)

Logging (for audit trail)

bash
Copy
Edit
aws s3api put-bucket-versioning \
  --bucket org-datalake-raw \
  --versioning-configuration Status=Enabled
## 2. 📥 Ingest Data to S3
Raw data can come from:

Autosys/Unix jobs (Use Case 1)

GoldenGate replication (Use Case 2)

Manual uploads (Use Case 3)

Each domain or source system gets its own folder prefix.

## 3. 📊 Register in Glue Catalog
Use Glue Crawlers to:

Detect new files and schemas

Register tables under a “raw” database

Example Table:

sql
Copy
Edit
CREATE EXTERNAL TABLE raw.transactions (
    txn_id STRING,
    amount DECIMAL(10,2),
    txn_type STRING,
    customer_id STRING
)
PARTITIONED BY (year STRING, month STRING, day STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
LOCATION 's3://org-datalake-raw/transactions/';
## 4. 🔍 Query Raw Data Using Athena
Once crawled:

sql
Copy
Edit
SELECT * FROM raw.transactions
WHERE year = '2025' AND day = '27'
AND txn_type = 'Withdrawal';
## 5. 🔐 Security & Compliance
Feature	Configuration
Encryption	SSE-S3 / SSE-KMS
IAM Policies	Fine-grained access by folder/path
Bucket Policies	Optional cross-account access
Versioning	Prevent accidental data loss or corruption
Access Logging	Enable for audit/compliance

## ✅ Benefits of Use Case 4
Feature	Value
Centralization	Single location for all raw data
Traceability	Supports audit and governance
Flexibility	Ingest from multiple sources
Schema-on-read	No transformation at this stage – preserve fidelity
Reusability	Serve downstream apps, ML, reports, etc.
