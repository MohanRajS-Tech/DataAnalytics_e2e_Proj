/* 
   DATA VALIDATION SUITE (DQA)
   Project: Nordcart E-commerce Optimization
   Author: Mohan Raj S
   Description: A professional testing suite to ensure data integrity before business analysis.
*/

-- ============================================================================
-- 1. DATA INTEGRITY & CONSTRAINTS
-- ============================================================================

-- CHECK: Null values in critical business columns
-- Expected Result: 0 rows
SELECT 'Null Check' AS test_name, COUNT(*) AS failed_records
FROM orders
WHERE order_id IS NULL OR customer_id IS NULL OR revenue IS NULL;

-- CHECK: Duplicate Order IDs (Primary Key Validation)
-- Expected Result: 0 rows
SELECT order_id, COUNT(*)
FROM orders
GROUP BY 1
HAVING COUNT(*) > 1;

-- CHECK: Referential Integrity (Foreign Key Validation)
-- Ensure every order's product exists in the product catalog
-- Expected Result: 0 rows
SELECT COUNT(o.product_id) AS orphaned_orders
FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================================
-- 2. BUSINESS LOGIC VALIDATION (Edge Case Testing)
-- ============================================================================

-- CHECK: Temporal Logic (Signup before Purchase)
-- Expected Result: 0 rows
SELECT COUNT(*) AS temporal_anomalies
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date < c.signup_date;

-- CHECK: Financial Boundaries (Non-negative values)
-- Expected Result: 0 rows
SELECT COUNT(*) AS negative_revenue_records
FROM orders
WHERE revenue < 0 OR base_price < 0;


-- ============================================================================
-- 3. DATA CLEANING & STANDARDIZATION
-- ============================================================================

-- CHECK: Channel Name Consistency
-- Identify any variations like 'PaidSearch' vs 'Paid Search'
-- Expected Result: Should only return standardized names
SELECT DISTINCT channel
FROM customers;

-- CHECK: Join Multiplicity Prevention (Many-to-Many Audit)
-- Pre-aggregation check for Problem Statement 1
WITH daily_counts AS (
    SELECT order_date, channel, COUNT(*) as row_count
    FROM orders
    GROUP BY 1, 2
)
SELECT * FROM daily_counts WHERE row_count > 1 LIMIT 5; 
-- Note: Multiple orders per day/channel is normal, 
-- but this reminds us to AGGREGATE before joining to marketing_spend.
