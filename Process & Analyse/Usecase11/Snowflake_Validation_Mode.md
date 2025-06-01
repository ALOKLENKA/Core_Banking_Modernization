In Snowflake, validation mode refers to a feature used with the COPY INTO command when loading data into tables from external sources (like S3). It allows you to validate the data without actually loading it into the table.

✅ What is VALIDATION_MODE in Snowflake?
VALIDATION_MODE is an option in the COPY INTO command that lets you check for errors in your data files before or without inserting any data.

🔍 Why Use VALIDATION_MODE?
To pre-check the format and schema compatibility

To identify rows that will cause load failures

To run dry runs for debugging and data quality validation

To check for issues like:

Missing fields

Type mismatches

Extra columns

Malformed rows

🔧 Syntax
sql
Copy
Edit
COPY INTO <table_name>
FROM <stage_path>
FILE_FORMAT = (TYPE = 'CSV')
VALIDATION_MODE = 'RETURN_ALL_ERRORS';
🎯 VALIDATION_MODE Options
Option	Description
'RETURN_ERRORS'	Returns one error row (default behavior when loading fails)
'RETURN_ALL_ERRORS'	Returns all rows that would fail during the load
'RETURN_1'	Returns only the first row that would be inserted (for test loads)

🧪 Example Use Case: Preview Errors from Raw CSV
sql
Copy
Edit
COPY INTO my_table
FROM @my_s3_stage/raw.csv
FILE_FORMAT = (TYPE = 'CSV')
VALIDATION_MODE = 'RETURN_ALL_ERRORS';
This command will return a list of all rows with issues, such as incorrect data types, missing values, etc., without inserting any rows.

📄 Output Example
text
Copy
Edit
| LINE | ERROR                                  | COLUMN_NAME | VALUE       |
|------|----------------------------------------|-------------|-------------|
| 3    | Numeric value 'abc' is not recognized  | amount      | abc         |
| 5    | Missing value in column 'created_at'   | created_at  | NULL        |
✅ Summary
Feature	Description
Purpose	Validate data before loading into Snowflake
Used With	COPY INTO
Common Mode	VALIDATION_MODE = 'RETURN_ALL_ERRORS'
Benefits	Catch errors early, improve data quality

Would you like an automated example using COPY INTO + VALIDATION_MODE + Task to run validations daily on incoming files?






You said:
yes


ChatGPT said:
Great! Here's how to automate a daily data validation process in Snowflake using:

✅ COPY INTO with VALIDATION_MODE = 'RETURN_ALL_ERRORS'

📂 Files in S3 (or Azure/GCS)

🕒 Snowflake Task to run daily

🔒 Optional: Use a staging table or log table to store errors

🔧 Step-by-Step Setup
🔹 Step 1: Create a File Format
sql
Copy
Edit
CREATE OR REPLACE FILE FORMAT my_csv_format
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1;
🔹 Step 2: Create an External Stage (e.g., S3)
sql
Copy
Edit
CREATE OR REPLACE STAGE my_stage
URL = 's3://my-bucket/my-folder/'
STORAGE_INTEGRATION = my_s3_integration
FILE_FORMAT = my_csv_format;
🔹 Step 3: Create a Table to Log Validation Errors
sql
Copy
Edit
CREATE OR REPLACE TABLE validation_errors (
  file_name STRING,
  line NUMBER,
  column_name STRING,
  error STRING,
  value STRING,
  validation_timestamp TIMESTAMP
);
🔹 Step 4: Create a Stored Procedure to Run Validation
sql
Copy
Edit
CREATE OR REPLACE PROCEDURE run_validation()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    validation_result RESULTSET;
BEGIN
    LET validation_result = (
        COPY INTO dummy_table
        FROM @my_stage
        FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')
        VALIDATION_MODE = 'RETURN_ALL_ERRORS'
    );

    INSERT INTO validation_errors (file_name, line, column_name, error, value, validation_timestamp)
    SELECT
        METADATA$FILENAME,
        VALUE:line::NUMBER,
        VALUE:column_name::STRING,
        VALUE:error::STRING,
        VALUE:value::STRING,
        CURRENT_TIMESTAMP
    FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

    RETURN 'Validation complete';
END;
$$;
⚠️ dummy_table is a placeholder table with the expected schema but no data.

🔹 Step 5: Schedule with a Task to Run Daily
sql
Copy
Edit
CREATE OR REPLACE TASK daily_data_validation
WAREHOUSE = my_wh
SCHEDULE = 'USING CRON 0 2 * * * UTC' -- Runs daily at 2 AM UTC
AS
CALL run_validation();
🔹 Step 6: Start the Task
sql
Copy
Edit
ALTER TASK daily_data_validation RESUME;
✅ What This Setup Does
Component	Purpose
FILE FORMAT	Defines how your raw data is structured
STAGE	Points to your S3 bucket/folder
COPY INTO	Validates incoming data using RETURN_ALL_ERRORS
RESULT_SCAN	Extracts errors from the last query
TASK	Automates the process to run every day
validation_errors	Stores the validation results for reporting/alerting

📌 Optional Add-ons
✅ Email/Slack alert if validation_errors has rows

📊 Create a dashboard in Snowsight or Power BI for validation monitoring

🛠️ Automatically move bad files to a "quarantine" folder in S3
