USE DATABASE LANGUAGE_APP_DB;

DROP TABLE IF EXISTS analytics.fact_session;
DROP TABLE IF EXISTS analytics.dim_users;

-- Although USER_ID and SESSION_ID are unique and non-NULL, 
-- surrogate integer keys are used to follow dimensional modelling best practices
-- and they can reduce key storage and join costs.

-- Create DIM_USERS TABLE 
CREATE TABLE analytics.dim_users (
    user_key         INT AUTOINCREMENT PRIMARY KEY,
    user_id          VARCHAR NOT NULL UNIQUE,
    name             VARCHAR,
    age              SMALLINT,
    country          VARCHAR,
    native_language  VARCHAR,
    app              VARCHAR,
    subscription_type VARCHAR,
    start_date       DATE,
    end_date         DATE,
    start_level_cefr VARCHAR,
    end_level_cefr   VARCHAR,
    start_level_number SMALLINT,
    end_level_number   SMALLINT
);


INSERT INTO analytics.dim_users (
    user_id,
    name,
    age,
    country,
    native_language,
    app,
    subscription_type,
    start_date,
    end_date,
    start_level_cefr,
    end_level_cefr,
    start_level_number,
    end_level_number
)
SELECT DISTINCT
    user_id,
    name,
    age,
    country,
    native_language,
    app,
    subscription_type,
    start_date,
    end_date,
    start_level_cefr,
    end_level_cefr,
    start_level_number,
    end_level_number
FROM intermediate.clean_apps_data
ORDER BY user_id;


SELECT *
FROM analytics.dim_users
ORDER BY user_key;


-- Create FACT_SESSION TABLE
CREATE TABLE analytics.fact_session (
    session_key INT AUTOINCREMENT PRIMARY KEY,
    session_id VARCHAR NOT NULL UNIQUE,
    session_timestamp TIMESTAMP,
    user_key INT NOT NULL
        REFERENCES analytics.dim_users(user_key),
    session_duration_mins SMALLINT
);


INSERT INTO analytics.fact_session (
    session_id,
    session_timestamp,
    user_key,
    session_duration_mins
)
SELECT
    cad.session_id,
    cad.session_timestamp,
    du.user_key,
    cad.session_duration_mins
FROM intermediate.clean_apps_data cad
JOIN analytics.dim_users du
    ON cad.user_id = du.user_id
ORDER BY cad.session_id;


SELECT *
FROM analytics.fact_session;

SELECT *
FROM analytics.dim_users
ORDER BY user_key;