
# Updated Use Case 12 – Write Cleansed Data to Snowflake
## 🎯 Goal:
Transform raw data from S3 → validate → cleanse → write to Snowflake Silver Layer using AWS Glue + PySpark.

## 🧱 Updated Architecture
css
Copy
Edit
[S3/raw/] ──> [AWS Glue Job (PySpark)]
                 ↓
     [Validation, Cleansing, Formatting]
                 ↓
          [Snowflake (Silver Layer Table)]
## 🔐 Pre-Requisites
Snowflake JDBC connection (via Glue connection).

Snowflake IAM role setup (via AWS Secrets Manager or hardcoded for PoC).

Snowflake database, schema, and table (silver.transaction_cleaned) created.

## 🧾 Updated PySpark Glue Script
Here’s a revised version of the Glue job that writes the cleansed data to Snowflake:

python
Copy
Edit
import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

# Init Glue context
glueContext = GlueContext(SparkContext.getOrCreate())
spark = glueContext.spark_session
job = Job(glueContext)
job.init('glue_to_snowflake_silver', args)

# Step 1: Read from Glue Catalog (raw data in S3)
raw_dyf = glueContext.create_dynamic_frame.from_catalog(
    database="banking_db",
    table_name="raw_transaction_data"
)

# Step 2: Convert to Spark DataFrame for cleansing
df = raw_dyf.toDF()

# Step 3: Apply validation logic
df_clean = df.filter("amount >= 0 AND currency IN ('USD', 'CAD', 'EUR')") \
             .filter("transaction_id IS NOT NULL AND transaction_timestamp IS NOT NULL")

# Optional: Format timestamp
from pyspark.sql.functions import to_timestamp
df_clean = df_clean.withColumn("transaction_timestamp", to_timestamp("transaction_timestamp"))

# Step 4: Write to Snowflake Silver Table
sfOptions = {
  "sfURL": "<account>.snowflakecomputing.com",
  "sfUser": "<your_snowflake_user>",
  "sfPassword": "<your_password_or_use_secret_manager>",
  "sfDatabase": "BANKING_ANALYTICS",
  "sfSchema": "SILVER",
  "sfWarehouse": "COMPUTE_WH",
  "sfRole": "SYSADMIN",
  "dbtable": "TRANSACTION_CLEANED"
}

df_clean.write \
    .format("snowflake") \
    .options(**sfOptions) \
    .mode("overwrite") \
    .save()

job.commit()

## 🔐 Best Practices
Area	Recommendation
Auth	Use AWS Secrets Manager to store sfUser and sfPassword.
Schema Mapping	Use Snowflake’s case-sensitive column mapping if needed.
Data Types	Ensure PySpark → Snowflake data types are mapped correctly.
Batch Size	Default batch size is 16000; tune it for performance.
Mode	Use "overwrite" or "append" carefully. Consider "merge" logic with streams for CDC.
Partitioning	Pre-aggregate before sending, as Snowflake handles partitions internally.

🧪 Example Target Table in Snowflake
sql
Copy
Edit
CREATE TABLE SILVER.TRANSACTION_CLEANED (
  TRANSACTION_ID STRING,
  ACCOUNT_ID STRING,
  AMOUNT FLOAT,
  CURRENCY STRING,
  TRANSACTION_TIMESTAMP TIMESTAMP,
  BRANCH_CODE STRING
);
🔍 Monitoring
Enable CloudWatch Logs in Glue.

Monitor Snowflake Task History for job execution stats.

Use Snowflake's Query History to verify loads.
