-- Create WH 
CREATE WAREHOUSE IF NOT EXISTS LANGUAGE_APP_WH
WITH 
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    SCALING_POLICY = 'ECONOMY';

USE WAREHOUSE LANGUAGE_APP_WH;


-- Create DB 
CREATE DATABASE IF NOT EXISTS LANGUAGE_APP_DB;
USE DATABASE LANGUAGE_APP_DB;


-- Create Storage Integration
CREATE STORAGE INTEGRATION IF NOT EXISTS gcp_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = GCS
    ENABLED = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('gcs://language-app-performance-data/');

DESC STORAGE INTEGRATION gcp_integration;


-- Create Schemas
CREATE SCHEMA IF NOT EXISTS external_stages;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS intermediate;
CREATE SCHEMA IF NOT EXISTS analytics;


-- Create Stage
CREATE STAGE IF NOT EXISTS external_stages.gcp_stage
    URL = 'gcs://language-app-performance-data/'
    STORAGE_INTEGRATION = gcp_integration
    FILE_FORMAT = (
            TYPE = CSV 
            FIELD_DELIMITER = ','
            SKIP_HEADER = 1
    );

LIST @external_stages.gcp_stage;


-- Infer_schema()
CREATE OR REPLACE FILE FORMAT staging.csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    PARSE_HEADER = TRUE;

SELECT *
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@external_stages.gcp_stage',
        FILE_FORMAT => 'staging.csv_format'
    )
);


-- Value inspection
CREATE OR REPLACE FILE FORMAT staging.csv_format_check
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 0;
    
SELECT
    $1, $2, $3, $4, $5, $6, $7,
    $8, $9, $10, $11, $12, $13, $14
FROM @external_stages.gcp_stage
(FILE_FORMAT => 'staging.csv_format_check')
LIMIT 10;


-- Import all raw data as varchar
CREATE TABLE IF NOT EXISTS staging.raw_apps_data (
    session_id VARCHAR,
    session_timestamp VARCHAR,
    user_id VARCHAR,
    name VARCHAR,
    age VARCHAR,
    country VARCHAR,
    native_language VARCHAR,
    app VARCHAR,
    subscription_type VARCHAR,
    start_date VARCHAR,
    end_date VARCHAR,
    start_level VARCHAR,
    end_level VARCHAR,
    session_duration_mins VARCHAR
);


COPY INTO staging.raw_apps_data 
    FROM @external_stages.gcp_stage;


SELECT *
FROM staging.raw_apps_data;
