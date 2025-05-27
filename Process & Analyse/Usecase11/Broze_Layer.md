%md

# Use Case 11: Raw Data (Bronze Layer) Load to Snowflake
## Goal: Copy raw files from AWS S3 to Snowflake with Zero Copy Cloning or basic COPY INTO for the Bronze Layer.

## 🔍 Context
You’ve already stored raw files (CSV, JSON, or Parquet) in an S3 data lake under a raw/ prefix. Now, you want to load this data into Snowflake for further processing in Silver/Gold layers.

## ✅ Implementation Plan
🏗️ Step 1: Create Required Snowflake Objects
- Stage: External stage pointing to your S3 bucket

- File Format: Define how your files are structured

- Table: Raw table with columns matching the file structure

- COPY INTO: Ingest data

## 📌 Example: Load Raw Transactional Data from S3
### 1. Create Stage
sql
Copy
Edit
CREATE OR REPLACE STAGE raw_data_stage
  URL = 's3://your-bucket-name/raw/'
  STORAGE_INTEGRATION = your_snowflake_s3_integration
  FILE_FORMAT = raw_csv_format;
STORAGE_INTEGRATION must be pre-configured to allow Snowflake to access S3.

### 2. Create File Format
sql
Copy
Edit
CREATE OR REPLACE FILE FORMAT raw_csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  FIELD_DELIMITER = ','
  NULL_IF = ('NULL', 'null', '');
### 3. Create Raw Table
sql
Copy
Edit
CREATE OR REPLACE TABLE raw_transaction_data (
  transaction_id STRING,
  customer_id STRING,
  transaction_type STRING,
  amount NUMBER(18,2),
  currency STRING,
  transaction_timestamp TIMESTAMP
);
### 4. Load Data using COPY INTO
sql
Copy
Edit
COPY INTO raw_transaction_data
FROM @raw_data_stage
FILE_FORMAT = (FORMAT_NAME = raw_csv_format)
ON_ERROR = 'SKIP_FILE'
PATTERN = '.*\.csv';

## 🔄 Optional: Zero-Copy Cloning
If you have a staging or raw table and want to clone it:

sql
Copy
Edit
CREATE OR REPLACE TABLE raw_transaction_data_clone CLONE raw_transaction_data;
Zero Copy Clone is useful for sandbox testing, UAT, backups, and avoids data duplication.

## ✅ Best Practices
Area	Recommendation
File Format	Use columnar formats like Parquet for efficiency
Partitioning	Organize S3 data by year/month/day
Naming Convention	Use consistent prefixes: raw/, processed/, reports/
Monitoring	Use Snowflake’s query history + CloudWatch for S3 access
Security	Restrict access to the external stage via IAM policies

# Snowpipe implementation
Here’s how you can implement Use Case 11 using Snowpipe in Snowflake for near real-time ingestion of raw data from AWS S3 into the Bronze Layer:

## ✅ Use Case 11 with Snowpipe
Goal: Automate raw data ingestion from S3 into a Snowflake table using Snowpipe.

📌 Architecture Overview
css
Copy
Edit
[S3 raw/ bucket] ──> [S3 Event Notification] ──> [SNS/SQS] ──> [Snowpipe] ──> [Raw Snowflake Table]
🔧 Step-by-Step Implementation
🛠️ Prerequisites
A Snowflake storage integration

An IAM role for Snowflake with access to your S3 bucket

S3 bucket has event notifications enabled

An external stage defined in Snowflake

## 1️⃣ Create a Storage Integration
sql
Copy
Edit
CREATE OR REPLACE STORAGE INTEGRATION s3_raw_data_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<account-id>:role/snowflake-s3-access-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket-name/raw/');
After this, Snowflake returns an external_id and user_arn — needed when configuring trust with IAM.

## 2️⃣ Create an External Stage
sql
Copy
Edit
CREATE OR REPLACE STAGE raw_data_stage
  URL = 's3://your-bucket-name/raw/'
  STORAGE_INTEGRATION = s3_raw_data_integration
  FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
3️⃣ Create Target Table
sql
Copy
Edit
CREATE OR REPLACE TABLE raw_transaction_data (
  transaction_id STRING,
  customer_id STRING,
  transaction_type STRING,
  amount NUMBER(18,2),
  currency STRING,
  transaction_timestamp TIMESTAMP
);
## 4️⃣ Create Snowpipe
sql
Copy
Edit
CREATE OR REPLACE PIPE raw_data_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO raw_transaction_data
  FROM @raw_data_stage
  FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
  ON_ERROR = 'SKIP_FILE';
## 5️⃣ Configure S3 Event Notifications (outside Snowflake)
In the S3 console, set up an event notification on the raw/ prefix.

- Trigger on ObjectCreated events.

- Send the notification to SNS or SQS.

- Ensure Snowflake’s IAM role is subscribed and has access.

## ✅ Best Practices for Banking Data
Best Practice	Description
Encryption	Enable S3 SSE or KMS encryption for raw data
Validation	Store a record of ingestion (e.g., into a log table)
Monitoring	Use Snowflake’s PIPE_USAGE_HISTORY and alert on failures
Retention	Archive or purge old files using S3 Lifecycle rules

## 📈 Monitoring Snowpipe
sql
Copy
Edit
SELECT *
FROM TABLE(information_schema.pipe_usage_history())
WHERE pipe_name = 'RAW_DATA_PIPE'
  AND start_time >= DATEADD(hour, -24, CURRENT_TIMESTAMP());
