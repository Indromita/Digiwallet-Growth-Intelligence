-- creating the database
CREATE DATABASE IF NOT EXISTS fintech_db;
USE fintech_db; 
-- creating the table
CREATE TABLE digital_transactions (
idx INT PRIMARY KEY,
transaction_id VARCHAR(50) UNIQUE NOT NULL,
user_id VARCHAR (50) NOT NULL,
transaction_date DATETIME NOT NULL,
product_category VARCHAR (100),
product_name VARCHAR (255),
merchant_name VARCHAR (255),
product_amount DECIMAL (15, 2), 
transaction_fee DECIMAL ( 15, 2), 
cashback DECIMAL (15, 2) DEFAULT 0.00, 
loyalty_points INT DEFAULT 0, 
payment_method VARCHAR( 50), 
transaction_status VARCHAR (20),
merchant_id VARCHAR(50), 
device_type VARCHAR (50),
location VARCHAR (100)
);



SELECT * FROM digital_transactions;

-- checking for Successful transactions with 0 or negative amounts
SELECT * FROM digital_transactions 
WHERE transaction_status = 'Successful' AND product_amount <= 0;
-- checking for null values
SELECT * FROM digital_transactions
WHERE user_id IS NULL;
SELECT * FROM digital_transactions
WHERE transaction_date IS NULL; 
SELECT SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END ) AS nullcategory,
       SUM( CASE WHEN product_amount IS NULL THEN 1 ELSE 0 END) AS prodamt,
       SUM( CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS paymeth,
       SUM( CASE WHEN merchant_id IS NULL THEN 1 ELSE 0 END) AS merchID,
       SUM( CASE WHEN transaction_status IS NULL THEN 1 ELSE 0 END ) AS transtat
       FROM digital_transactions;
-- checking for logical integrity
SELECT COUNT(*) FROM digital_transactions
WHERE transaction_date > NOW();

SELECT COUNT(*) FROM digital_transactions
WHERE transaction_fee > product_amount;
SELECT product_category, merchant_name, product_amount, transaction_fee,payment_method, transaction_status 
FROM digital_transactions
WHERE transaction_fee> product_amount
ORDER BY product_amount DESC;
-- calculating the percentage of the fee relative to the amount
SELECT product_category, product_amount, transaction_fee, ROUND((transaction_fee/product_amount*100),2) AS fee_percent
FROM digital_transactions;

-- adding a flag column for negative margins
ALTER TABLE digital_transactions ADD COLUMN txn_efficiency_flag VARCHAR(50);
SET SQL_SAFE_UPDATES = 0; 


UPDATE digital_transactions
SET txn_efficiency_flag = CASE 
    WHEN (product_amount = 0 OR product_amount IS NULL) THEN 'Data Error'
    WHEN (transaction_fee > product_amount) THEN 'Negative Margin'
    WHEN (transaction_fee / product_amount * 100) > 15 THEN 'High Friction'
    ELSE 'Optimized'
END;

SET SQL_SAFE_UPDATES = 1;

SELECT 
    CASE 
        WHEN product_amount <= 50 THEN '0-50 (Micro)'
        WHEN product_amount <= 200 THEN '51-200 (Small)'
        WHEN product_amount <= 1000 THEN '201-1000 (Medium)'
        ELSE '1000+ (Large)'
    END AS amount_bucket,
    txn_efficiency_flag, 
    COUNT(*) AS total_txns,
    ROUND(AVG(transaction_fee / product_amount * 100), 2) AS avg_fee_percent
FROM digital_transactions
GROUP BY amount_bucket, txn_efficiency_flag
ORDER BY MIN(product_amount);

-- checking for standardization needs
SELECT product_category, COUNT(*)
FROM digital_transactions
GROUP BY product_category;
-- validation query
SELECT 
   product_category, LOWER(TRIM(product_category)) AS clean_name, 
    COUNT(*) AS frequency
FROM digital_transactions
GROUP BY product_category,clean_name
ORDER BY frequency DESC;

SELECT 
    merchant_name, 
    LOWER(TRIM(merchant_name)) AS clean_merchant, 
    COUNT(*) AS frequency
FROM digital_transactions
GROUP BY merchant_name, clean_merchant
ORDER BY frequency DESC;

-- checking for dates
DESCRIBE digital_transactions;

SELECT transaction_date, COUNT(*) 
FROM digital_transactions 
GROUP BY transaction_date 
ORDER BY transaction_date 
LIMIT 20;


-- Frequency distribution to check the churn vs retention ratio
SELECT 
    sub.tranNo, 
    COUNT(sub.user_id) AS number_of_users
FROM (
    SELECT user_id, COUNT(*) AS tranNo 
    FROM digital_transactions 
    GROUP BY user_id
) AS sub
GROUP BY sub.tranNo
ORDER BY sub.tranNo DESC;


-- cohort analysis
SELECT 
    sub.total_txns_first_week,
    COUNT(sub.user_id) AS user_count
FROM (
    SELECT 
        user_id, 
        COUNT(*) AS total_txns_first_week
    FROM digital_transactions
    WHERE transaction_date <= DATE_ADD((SELECT MIN(transaction_date) FROM digital_transactions), INTERVAL 7 DAY)
    GROUP BY user_id
) AS sub
GROUP BY sub.total_txns_first_week
ORDER BY sub.total_txns_first_week ASC;

SELECT 
    sub.total_txns_30_days,
    COUNT(sub.user_id) AS user_count
FROM (
    SELECT 
        user_id, 
        COUNT(*) AS total_txns_30_days
    FROM digital_transactions
    WHERE transaction_date <= DATE_ADD((SELECT MIN(transaction_date) FROM digital_transactions), INTERVAL 30 DAY)
    GROUP BY user_id
) AS sub
GROUP BY sub.total_txns_30_days
ORDER BY sub.total_txns_30_days ASC;


-- segmenting users based on engagement 
SELECT 
    CASE 
        WHEN txn_count = 1 THEN 'One-Hit Wonder'
        WHEN txn_count BETWEEN 2 AND 5 THEN 'Casual User'
        WHEN txn_count BETWEEN 6 AND 20 THEN 'Core User'
        ELSE 'Power User (Whale)'
    END AS user_segment,
    COUNT(*) AS number_of_users,
    AVG(txn_count) AS avg_txns_per_user
FROM (
    SELECT user_id, COUNT(*) AS txn_count 
    FROM digital_transactions 
    GROUP BY user_id
) AS user_stats
GROUP BY user_segment;


-- churn deep dive 
CREATE VIEW one_hit_wonder_analysis AS
SELECT 
    product_category,
    txn_efficiency_flag,
    COUNT(*) AS user_count,
    ROUND(AVG(transaction_fee / product_amount * 100), 2) AS avg_fee_percent
FROM digital_transactions
WHERE user_id IN (
    SELECT user_id 
    FROM digital_transactions 
    GROUP BY user_id 
    HAVING COUNT(*) = 1
)
GROUP BY product_category, txn_efficiency_flag;

SELECT * FROM one_hit_wonder_analysis;


-- retained deep dive
SELECT 
    product_category,
    COUNT(*) AS frequency,
    COUNT(DISTINCT user_id) AS unique_users_using_this
FROM digital_transactions
WHERE user_id IN (
    -- Only looking at users who stayed (4+ transactions total)
    SELECT user_id 
    FROM digital_transactions 
    GROUP BY user_id 
    HAVING COUNT(*) >= 4
)
-- Looking only at their first 30 days of behavior
AND transaction_date <= DATE_ADD((SELECT MIN(transaction_date) FROM digital_transactions), INTERVAL 30 DAY)
GROUP BY product_category
ORDER BY frequency DESC;

SELECT 
    product_category,
    COUNT(*) AS frequency,
    COUNT(DISTINCT user_id) AS unique_users
FROM digital_transactions AS t1
WHERE user_id IN (
    -- Still targeting the Retained Users
    SELECT user_id 
    FROM digital_transactions 
    GROUP BY user_id 
    HAVING COUNT(*) >= 4
)
AND transaction_date <= (
    SELECT DATE_ADD(MIN(transaction_date), INTERVAL 30 DAY)
    FROM digital_transactions AS t2
    WHERE t1.user_id = t2.user_id
)
GROUP BY product_category
ORDER BY frequency DESC;

SELECT 
    product_category,
    COUNT(*) AS frequency,
    COUNT(DISTINCT user_id) AS unique_users
FROM digital_transactions AS t1
WHERE user_id IN (
    -- Targeting the One-Hit Wonders (exactly 1 txn total)
    SELECT user_id 
    FROM digital_transactions 
    GROUP BY user_id 
    HAVING COUNT(*) = 1
)
AND transaction_date <= (
    -- Looking at their first 30 days (which is their only day)
    SELECT DATE_ADD(MIN(transaction_date), INTERVAL 30 DAY)
    FROM digital_transactions AS t2
    WHERE t1.user_id = t2.user_id
)
GROUP BY product_category
ORDER BY frequency DESC;


-- date sanity check
SELECT 
    MIN(transaction_date) AS earliest_date, 
    MAX(transaction_date) AS latest_date,
    DATEDIFF(MAX(transaction_date), MIN(transaction_date)) AS total_days_in_data,
    COUNT(DISTINCT transaction_date) AS unique_days_with_activity
FROM digital_transactions;

-- product category performance
SELECT 
    product_category,
    -- People who left after 1 try
    COUNT(CASE WHEN user_id IN (SELECT user_id FROM digital_transactions GROUP BY user_id HAVING COUNT(*) = 1) THEN 1 END) AS churned_after_one,
    -- People who came back at least once 
    COUNT(CASE WHEN user_id IN (SELECT user_id FROM digital_transactions GROUP BY user_id HAVING COUNT(*) >= 2) THEN 1 END) AS returned_for_more
FROM digital_transactions
GROUP BY product_category
ORDER BY returned_for_more DESC;


-- identifying high retention product categories for future onboarding
SELECT 
    product_category,
    -- How many times Retained Users (4+ txns) used this
    COUNT(CASE WHEN user_id IN (SELECT user_id FROM digital_transactions GROUP BY user_id HAVING COUNT(*) >= 4) THEN 1 END) AS power_user_txns,
    -- How many times Churned Users (1 txn) used this
    COUNT(CASE WHEN user_id IN (SELECT user_id FROM digital_transactions GROUP BY user_id HAVING COUNT(*) = 1) THEN 1 END) AS churn_user_txns
FROM digital_transactions
GROUP BY product_category
ORDER BY power_user_txns DESC;


-- is the fee really a churn driver? 
SELECT 
    CASE WHEN user_id IN (SELECT user_id FROM digital_transactions GROUP BY user_id HAVING COUNT(*) = 1) THEN 'One-Time User' ELSE 'Repeat User' END AS user_type,
    txn_efficiency_flag,
    COUNT(*) AS count,
    ROUND(AVG(transaction_fee / product_amount * 100), 2) AS avg_fee_percent
FROM digital_transactions
GROUP BY user_type, txn_efficiency_flag
ORDER BY user_type, avg_fee_percent DESC;



SELECT * FROM digital_transactions;
SELECT 
    SUB.tranNo, 
    AVG(SUB.product_amount) AS avg_amt
FROM (
    SELECT 
        user_id, 
        product_amount, 
        product_category,
        COUNT(*) OVER(PARTITION BY user_id) AS tranNo 
    FROM digital_transactions
) AS SUB 
 GROUP BY SUB.tranNo
ORDER BY SUB.tranNo;


-- ltv calculation
SELECT 
    user_segment,
    COUNT(user_id) AS total_users,
    ROUND(SUM(total_revenue), 2) AS group_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_ltv, -- Lifetime Value
   -- Using ₹400 as a hypothetical CAC
ROUND(AVG(total_revenue) - 400.00, 2) AS net_profit_per_user_inr
FROM (
    SELECT 
        user_id,
        SUM(transaction_fee) AS total_revenue,
        CASE 
            WHEN COUNT(*) = 1 THEN '1. One-Time'
            WHEN COUNT(*) BETWEEN 2 AND 3 THEN '2. Repeat'
            ELSE '3. Loyal (4+)' 
        END AS user_segment
    FROM digital_transactions
    GROUP BY user_id
) AS user_finance
GROUP BY user_segment
ORDER BY user_segment;

-- breakeven calculation
SELECT 
    ROUND(AVG(transaction_fee), 2) AS avg_revenue_per_txn,
    400.00 AS cac,
    CEIL(400.00 / AVG(transaction_fee)) AS txns_to_breakeven
FROM digital_transactions;


