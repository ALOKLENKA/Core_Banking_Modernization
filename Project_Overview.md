%md
# Project: Core Banking Data Modernization (LATAM Region)
Scope: Modernizing legacy OLTP/OLAP systems to a cloud-based analytics platform on AWS.

## Legacy System Architecture
### Legacy Core Banking Platform (On-Premises)
#### Technological Stack:
Flexcube: Core banking product processor.
Oracle DB: Stores customer, accounts, and transaction data (credit/debit).
Kafka: Streams transactional data (fund transfers, deposits, withdrawals) to Flexcube and Oracle DB.
Fuse: Messaging/notification service for customer alerts.
Talend: Batch processing, upstream/downstream data exchange.
Orachestration: Autosys

### New Core Banking Platform( Hybrid= OLTP on prem + OLAP on AWS)
### Transaction Processing Plaform -on premises
#### Technological Stack:
Flexcube: Core banking product processor.
Oracle DB: Stores customer, accounts, and transaction data (credit/debit).
Kafka: Streams transactional data (fund transfers, deposits, withdrawals) to Flexcube and Oracle DB.
Orechestration: Autosys

# ☁️ Data Modernization Platform – AWS Cloud (OLAP)
#### Technological Stack:
Ingestion: AWS CLI itility push mechanism
Storage: AWS S3 Data Lake 
Data Anlytical processing: AWS Glue + Payspark + Snowflake
Data Visualization: Tabbleau
Orechestration: AWS Glue + Managed Airflow

## 🔄 Ingestion Layer
### Use Case 1:

- Upstream systems push files to S3.

- Unix server uses AWS CLI to upload files.

- Autosys File Watcher triggers scripts on flag file detection.

### Use Case 2:

- Oracle GoldenGate used to replicate transactional data to S3.

### Use Case 3:

Business users upload reference data to secure S3 buckets.

🗄️ Storage Layer – S3 Data Lake
Use Case 4:

Raw data stored as a single source of truth.

Use Case 5:

AWS Glue Crawler + Data Catalog for metadata management and schema evolution.

Use Case 6:

S3 Lifecycle Policies to optimize storage costs.

Use Case 7:

Versioning enabled to recover from accidental deletions.

Use Case 8:

Encryption at rest for data security.

Use Case 9:

Data partitioned by transaction year/date for performance.

Use Case 10:

Athena used to query the data lake.

🔧 Process & Analyze Layer – Snowflake
Use Case 11 (Bronze Layer):

Raw data copied using COPY INTO and Zero Data Copy approach.

Use Case 12 (Silver Layer):

Data cleansing/validation using Glue + PySpark.

Use Case 13 (Gold Layer):

Dimensional modeling and business logic transformation using Glue + PySpark.

Use Case 14:

Reports generated in CSV/JSON format and written to S3.

Use Case 15:

Reports pushed from S3 to downstream on-prem applications.

📊 Explore & Visualize – Tableau
Use Case 1:

Live connection with Snowflake.

Use Case 2:

Support for live queries.

Use Case 3:

Import queries for snapshot reporting.

Use Case 4:

Scheduling of report refreshes.

Use Case 5:

Sharing reports with business users/stakeholders.
