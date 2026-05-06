-- 1. Set up and loading data
CREATE DATABASE fraud_data_analytics;
USE fraud_data_analytics;

-- renaming the table
RENAME TABLE bank_transactions_data TO transactions;

-- keeping raw data as is
CREATE TABLE raw_data AS SELECT * FROM transactions;

-- 2. Preprocessing
-- renaming columns to snake case
ALTER TABLE transactions
    RENAME COLUMN TransactionID TO transaction_id,
    RENAME COLUMN AccountID TO account_id,
    RENAME COLUMN TransactionAmount TO transaction_amount,
    RENAME COLUMN TransactionDate TO transaction_date,
    RENAME COLUMN TransactionType TO transaction_type,
    RENAME COLUMN Location TO location,
    RENAME COLUMN DeviceID TO device_id,
    RENAME COLUMN `IP Address` TO ip_address,
    RENAME COLUMN MerchantID TO merchant_id,
    RENAME COLUMN `Channel` TO `channel`,
    RENAME COLUMN CustomerAge TO customer_age,
    RENAME COLUMN CustomerOccupation TO customer_occupation,
    RENAME COLUMN TransactionDuration TO transaction_duration,
    RENAME COLUMN LoginAttempts TO login_attempts,
    RENAME COLUMN AccountBalance TO account_balance;

-- standardising date field
-- SET SQL_SAFE_UPDATES = 0;
UPDATE transactions
SET transaction_date = DATE(
    STR_TO_DATE(transaction_date, '%m/%d/%Y %H:%i')
);

ALTER TABLE transactions
MODIFY COLUMN transaction_date DATE;
-- SET SQL_SAFE_UPDATES = 1;

-- 2. Checking data reliability
-- are there duplicate, missing, wrong ordered transaction_id
WITH id_check AS (
    SELECT
        transaction_id,
        -- stripping transaction_id from letters and convert string to numeric
        CAST(REGEXP_SUBSTR(transaction_id, '[0-9]+') AS UNSIGNED) AS numeric_id,
        LAG(CAST(REGEXP_SUBSTR(transaction_id, '[0-9]+') AS UNSIGNED)) OVER (
			ORDER BY CAST(REGEXP_SUBSTR(transaction_id, '[0-9]+') AS UNSIGNED)
		) AS prev_id
    FROM transactions
)
SELECT *,
       numeric_id - prev_id AS gap_size
FROM id_check
WHERE prev_id IS NULL
   OR numeric_id - prev_id <> 1;


-- Scenario 1: 
-- Data interrogation tests: volume anomaly/ amount anomaly/ fragmentation pattern

-- calculating daily activity: transactions per day and daily amount
CREATE TABLE scenario1_transaction_flags AS
WITH daily_activity AS (
    SELECT 
		account_id, 
        transaction_date, 
        COUNT(*) AS transactions_per_day, 
        SUM(transaction_amount) AS daily_amount
    FROM 
		transactions
    GROUP BY 
        account_id,
        transaction_date
),

-- calculating average daily amount per user 
daily_baseline AS (
    SELECT
        account_id,
        transaction_date,
        transactions_per_day,
        daily_amount,
        ROUND(
			AVG(daily_amount) OVER (
				PARTITION BY account_id
			), 
			2
		) AS avg_daily_amount
    FROM 
		daily_activity
),

-- establishing previous transaction amount within the same account-day
prev_amount_tb AS (
	SELECT 
		t.*,
        LAG(transaction_amount) OVER(
			PARTITION BY account_id, transaction_date 
            ORDER BY transaction_id
		) AS prev_amount
	FROM 
		transactions t
),

-- calculating current amount / previous amount ratio
amount_ratio_tb AS (
	SELECT 
		pa_tb.*,
        ROUND(
			transaction_amount / NULLIF(prev_amount, 0),
			2
		) AS amount_ratio
	FROM 
		prev_amount_tb pa_tb
),

-- putting everything together in one table
joined_tb AS (
	SELECT
		ar_tb.transaction_id,
        ar_tb.account_id,
        ar_tb.transaction_amount,
        ar_tb.transaction_date,
        ar_tb.amount_ratio,
        db.transactions_per_day,
        db.avg_daily_amount,
        db.daily_amount
	FROM 
		amount_ratio_tb ar_tb
	JOIN daily_baseline db
		ON db.account_id = ar_tb.account_id
		AND db.transaction_date = ar_tb.transaction_date
),

-- creating a score table with each type of flag
score_tb AS (
	SELECT 
        j.*,
        CASE
            WHEN transactions_per_day > 1 
            THEN 1 ELSE 0 
        END AS volume_flag,
    
        CASE
			WHEN daily_amount > 1.5 * avg_daily_amount 
            THEN 1 ELSE 0 
        END AS amount_flag,
    
        CASE
            WHEN amount_ratio BETWEEN 0.9 AND 1.1 
            THEN 1 ELSE 0 
        END AS fragmentation_flag
	FROM 
		joined_tb j
),

-- final table with total flags and each separate flags
total_flag_tb AS (
	SELECT
		s.*,
        volume_flag + amount_flag + fragmentation_flag AS total_flags
	FROM 
		score_tb s
)
	
SELECT
	transaction_id,
    account_id,
    volume_flag,
    amount_flag,
    fragmentation_flag,
    total_flags
FROM 
	total_flag_tb;

	

-- Scenario 2
-- Data interrogation tests: dormancy/ amount anomaly/ suspicious login

-- establishing previous previous date using lag
CREATE TABLE scenario2_transaction_flags AS
WITH prev_date_tb AS (
	SELECT
		transaction_id,
		account_id,
		transaction_amount,
		transaction_date,
		LAG(transaction_date) OVER(
			PARTITION BY account_id 
            ORDER BY transaction_date, transaction_id
		) AS prev_date,
        login_attempts
	FROM 
		transactions 
),

-- calculating time between each transaction
dormancy_tb AS (
	SELECT
		pd.*,
        TIMESTAMPDIFF(
			DAY, 
            prev_date, 
            transaction_date
		) AS days_since_last_transaction
	FROM 
		prev_date_tb pd
),

-- calculating average days between transactions and average transaction amount per account
user_baseline AS (
	SELECT
		account_id,
		ROUND(
			AVG(days_since_last_transaction), 
			0
        ) AS account_avg_days_between_transactions,
		MAX(days_since_last_transaction) AS max_days_between_transaction,
		ROUND(
			AVG(transaction_amount), 
			2
        ) AS account_avg_amount
	FROM 
		dormancy_tb
    GROUP BY 
		account_id
),

-- joining baseline and dormancy tables
joined_tb AS (
	SELECT
		d.*,
		ub.account_avg_days_between_transactions,
		ub.account_avg_amount
	FROM 
		dormancy_tb d
	JOIN user_baseline ub
		ON d.account_id = ub.account_id
),

-- creating a score table with each type of flag
score_tb AS (
	SELECT
		j.*,
        CASE
			WHEN days_since_last_transaction > 30
                 AND days_since_last_transaction > 2 * account_avg_days_between_transactions 
            THEN 1 ELSE 0
		END AS dormancy_flag,

        CASE
			WHEN transaction_amount > 1.5 * account_avg_amount 
            THEN 1 ELSE 0
		END AS amount_flag,

        CASE
			WHEN login_attempts > 2 
            THEN 1 ELSE 0
		END AS login_flag
	FROM 
		joined_tb j
),

-- final table with total flags and each separate flag count
total_flag_tb AS (
	SELECT
		transaction_id,
        account_id,
        transaction_date,
        transaction_amount,
        days_since_last_transaction,
        account_avg_days_between_transactions,
        account_avg_amount,
        login_attempts,
        dormancy_flag,
        amount_flag,
        login_flag,
        dormancy_flag + amount_flag + login_flag AS total_flags
	FROM 
		score_tb
)

SELECT 
	transaction_id,
	account_id,
	dormancy_flag,
	amount_flag,
	login_flag,
	total_flags
FROM 
	total_flag_tb;
    

-- creating a table which combines risk scores for scenario 1 & 2 and weighted risk category
CREATE TABLE combined_risk_flags AS
SELECT
    t.transaction_id,
    t.account_id,
    s1.total_flags AS scenario1_score,
    s2.total_flags AS scenario2_score,
    (s1.total_flags + s2.total_flags) AS total_risk_score,
    CASE
		WHEN COALESCE(s1.total_flags, 0) >= 2
			AND COALESCE(s2.total_flags, 0) >= 2
		THEN 'HIGH'
        
		WHEN COALESCE(s1.total_flags, 0) + COALESCE(s2.total_flags, 0) >= 3
		THEN 'MEDIUM'
        
		ELSE 'LOW'
	END AS risk_category
FROM transactions t
LEFT JOIN scenario1_transaction_flags s1
    ON t.transaction_id = s1.transaction_id
LEFT JOIN scenario2_transaction_flags s2
    ON t.transaction_id = s2.transaction_id;
    






    
