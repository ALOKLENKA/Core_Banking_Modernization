# Use Case 12 – Silver Layer: Data Validation, Cleansing & Formatting
## Objective: Transform raw transactional data into a cleaned and structured format (Silver Layer) using AWS Glue and PySpark.

## 📌 Architecture Overview
css
Copy
Edit
[S3/raw/] ──> [Glue Job (PySpark)] ──> [S3/processed/]  
                 ↓  
        [Validation, Cleansing, Formatting]
## 🧱 Components Involved
Component	Purpose
S3/raw/	Bronze layer – raw data source
AWS Glue Job	PySpark script for transformation
Glue Data Catalog	Schema management
S3/processed/	Silver layer – cleaned data output

## 🧪 Sample Data Validation Rules
Field	Rule
amount	Must be non-negative
currency	Must match ISO codes (e.g., "USD", "EUR")
transaction_id	Must not be null or duplicate
timestamp	Must be valid format & within range

🧠 Transformation Steps
Read data from S3/raw using a Glue Data Catalog table.

Filter invalid/malformed rows.

Cleanse data (e.g., trim strings, fill missing fields).

Format timestamps and number fields.

Write output to S3/processed in Parquet/CSV format.

## 🧾 Sample Glue PySpark Script
python
Copy
Edit
import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

glueContext = GlueContext(SparkContext.getOrCreate())
spark = glueContext.spark_session
job = Job(glueContext)
job.init('silver_layer_transform', args)

# Step 1: Load raw data from S3
raw_dyf = glueContext.create_dynamic_frame.from_catalog(
    database="banking_db",
    table_name="raw_transaction_data"
)

# Step 2: Convert to DataFrame for validation
df = raw_dyf.toDF()

# Step 3: Apply validation rules
df_clean = df.filter("amount >= 0 AND currency IN ('USD', 'CAD', 'GBP')") \
             .filter("transaction_id IS NOT NULL AND transaction_timestamp IS NOT NULL")

# Optional: Format timestamp
from pyspark.sql.functions import to_timestamp
df_clean = df_clean.withColumn("transaction_timestamp", to_timestamp("transaction_timestamp"))

# Step 4: Convert back to Glue DynamicFrame
dyf_clean = DynamicFrame.fromDF(df_clean, glueContext, "dyf_clean")

# Step 5: Write to Silver Layer (processed zone)
glueContext.write_dynamic_frame.from_options(
    frame=dyf_clean,
    connection_type="s3",
    connection_options={"path": "s3://your-bucket/processed/"},
    format="parquet"
)

job.commit()
⚙️ Recommended Configurations
Setting	Recommendation
Output Format	Parquet (compact + faster queries)
Partition Columns	transaction_year, transaction_date
Job Bookmark	Enable for incremental loading
Error Handling	Use onError=skip_record or custom log

📊 Monitoring & Logging
- Enable CloudWatch Logs for Glue jobs.

- Use Glue's Job Metrics for success/failure count.

- Log invalid records to a quarantine bucket for audit.
