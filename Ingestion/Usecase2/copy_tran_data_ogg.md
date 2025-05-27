%md

# Use Case 2: Ingest Transactional Data from Oracle DB to AWS S3 using GoldenGate
## 🎯 Goal
To continuously replicate transactional data (e.g., from Oracle Core Banking system) to an AWS S3 data lake using Oracle GoldenGate.

📐 Architecture Overview
pgsql
Copy
Edit
 ┌────────────────────┐
 │  Oracle Core DB    │ (On-Prem)
 │  └─ Transactions   │
 └────────┬───────────┘
          │
      [Oracle GoldenGate Extract]
          │
          ▼
 ┌────────────────────┐
 │ Trail Files (Local)│
 └────────┬───────────┘
          │
      [GoldenGate Distribution Pathway]
          │
          ▼
 ┌────────────────────┐
 │  AWS DMS / GG for  │
 │  Big Data / Custom │
 │     Handler        │
 └────────┬───────────┘
          │
          ▼
   ┌────────────────────┐
   │ Amazon S3 (Landing)│
   └────────────────────┘
### 🔧 Key Components
####  1. Oracle GoldenGate Extract & Replicat
Extracts from Oracle redo/archive logs.

Transforms to trail files.

Replicat pushes to S3 using GoldenGate for Big Data (GGBD) OR via custom handler + S3 sink.

#### 2. GoldenGate for Big Data (GGBD) → S3 Sink
GG Big Data supports native S3 target.

Output formats: JSON, AVRO, Parquet, etc.

### 💻 Sample Configuration Files
📝 ogg.properties for GoldenGate to S3
properties
Copy
Edit
gg.handlerlist=s3handler
gg.handler.s3handler.type=s3
gg.handler.s3handler.format=json
gg.handler.s3handler.mode=tx
gg.handler.s3handler.s3BucketName=banking-ingest-bucket
gg.handler.s3handler.rootDirectory=corebanking/transactions
gg.handler.s3handler.region=us-east-1
gg.handler.s3handler.fileRollSizeMB=100
gg.handler.s3handler.prefix=txn_
gg.handler.s3handler.fileSuffix=.json
gg.handler.s3handler.encryption=AES256
✅ This creates files in S3 like:
s3://banking-ingest-bucket/corebanking/transactions/txn_20250527.json

### 🔐 Authentication Options
Use IAM Role (if running on EC2 or container).

Or set static credentials in aws.properties:

properties
Copy
Edit
aws.accessKeyId=YOUR_ACCESS_KEY
aws.secretAccessKey=YOUR_SECRET_KEY
🛠️ Optional: Use AWS DMS + GoldenGate
GoldenGate writes to Kafka.

AWS DMS reads Kafka and writes to S3 (JSON/Parquet).

### 🧪 Output Sample: JSON Record in S3
json
Copy
Edit
{
  "table": "transactions",
  "operation": "INSERT",
  "timestamp": "2025-05-27T14:32:45Z",
  "data": {
    "txn_id": "TX123456",
    "account_no": "987654321",
    "amount": 150.00,
    "currency": "USD",
    "type": "DEBIT",
    "txn_date": "2025-05-27T14:30:00Z"
  }
}
### ✅ Benefits
Feature	Value
Real-time ingestion	Yes (near real-time using trail files)
Format	JSON/Parquet supported
Querying via Athena	Yes, once partitioned
Secure transfer	Yes (encryption + IAM policies)
