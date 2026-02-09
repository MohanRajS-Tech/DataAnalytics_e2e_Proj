-- ==========================================
-- SQL Views for NordCart Power BI Dashboard
-- Goal: Create a clean Star Schema layer
-- ==========================================

-- 1. Dimension: Products
-- Purpose: Standardize product attributes and margins
DROP VIEW IF EXISTS v_dim_products CASCADE;
CREATE OR REPLACE VIEW v_dim_products AS
SELECT 
    product_id,
    product_name,
    category,
    base_price,
    margin
FROM products;

-- 2. Dimension: Customers
-- Purpose: Standardize signup info and PRE-CALCULATE retention and segments
-- Senior Tip: By doing segmentation in SQL, we can use it on Chart Axes in Power BI.
DROP VIEW IF EXISTS v_dim_customers CASCADE;
CREATE OR REPLACE VIEW v_dim_customers AS
SELECT 
    customer_id,
    signup_date,
    CASE 
        WHEN channel = 'PaidSearch' THEN 'Paid Search' 
        ELSE channel 
    END AS channel,
    country
FROM customers;

-- 3. Dimension: Marketing Spend
-- Purpose: Clean marketing spend data for attribution
DROP VIEW IF EXISTS v_dim_marketing CASCADE;
CREATE OR REPLACE VIEW v_dim_marketing AS
SELECT 
    date,
    CASE 
        WHEN channel = 'PaidSearch' THEN 'Paid Search' 
        ELSE channel 
    END AS channel,
    spend
FROM marketing_spend;

-- 4. Dimension: Unique Channels (The "Bridge")
-- Purpose: Solve the "Duplicate Value" error in Power BI.
-- This table provides a list of ONLY UNIQUE channel names to act as the "1" side.
DROP VIEW IF EXISTS v_dim_channels CASCADE;
CREATE OR REPLACE VIEW v_dim_channels AS
SELECT DISTINCT
    CASE 
        WHEN channel = 'PaidSearch' THEN 'Paid Search' 
        ELSE channel 
    END AS channel
FROM orders;

-- 5. Fact: Orders
-- Purpose: The central table for all metrics. 
-- Senior Tip: We bake 'cohort_month' and 'tenure_month' here so the heatmap works 
-- even if you have relationship issues in Power BI ("God Mode" stability).
DROP VIEW IF EXISTS v_fact_orders CASCADE;
CREATE OR REPLACE VIEW v_fact_orders AS
SELECT 
    o.order_id,
    o.customer_id,
    o.product_id,
    o.order_date,
    o.category,
    CASE 
        WHEN o.channel = 'PaidSearch' THEN 'Paid Search' 
        ELSE o.channel 
    END AS channel,
    o.quantity,
    o.revenue,
    -- Pre-calculate Cohort Month for the Matrix ROWS
    TO_CHAR(c.signup_date, 'Mon YYYY') AS cohort_month,
    -- Pre-calculate Tenure Month for the Matrix COLUMNS
    CAST(((EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM c.signup_date)) * 12 + 
     EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM c.signup_date)) AS INT) AS tenure_month
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- 6. Fact: Website Sessions
-- Purpose: Track traffic to calculate Conversion Rates (CVR)
DROP VIEW IF EXISTS v_fact_sessions CASCADE;
CREATE OR REPLACE VIEW v_fact_sessions AS
SELECT 
    date,
    CASE 
        WHEN channel = 'PaidSearch' THEN 'Paid Search' 
        ELSE channel 
    END AS channel,
    sessions
FROM website_sessions;

-- 7. Analytics: Cohort Summary (The "Out of the Box" Fix)
-- Purpose: Pre-calculating survival rates so Power BI doesn't struggle with relationships.
-- This solves the "Zeros" and "Shuffling Month" errors.
DROP VIEW IF EXISTS v_cohort_summary CASCADE;
CREATE OR REPLACE VIEW v_cohort_summary AS
WITH cohort_sizes AS (
    SELECT 
        TO_CHAR(signup_date, 'YYYY-MM') as cohort_month,
        COUNT(customer_id) as total_customers
    FROM customers
    GROUP BY 1
),
retention_counts AS (
    SELECT 
        TO_CHAR(c.signup_date, 'YYYY-MM') as cohort_month,
        CAST(((EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM c.signup_date)) * 12 + 
         EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM c.signup_date)) AS INT) AS months_since_signup,
        COUNT(DISTINCT o.customer_id) as returning_customers
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY 1, 2
)
SELECT 
    r.cohort_month,
    r.months_since_signup,
    r.returning_customers,
    s.total_customers,
    CAST(r.returning_customers AS FLOAT) / s.total_customers as retention_rate
FROM retention_counts r
JOIN cohort_sizes s ON r.cohort_month = s.cohort_month
WHERE r.months_since_signup >= 0;

SELECT * FROM v_cohort_summary LIMIT 10;


SELECT * FROM v_dim_products;
SELECT * FROM v_dim_customers;
SELECT * FROM v_dim_channels;
SELECT * FROM v_dim_marketing;
SELECT * FROM v_fact_orders;
SELECT * FROM v_fact_sessions;

-- ==========================================
-- FINAL FIX: PRE-AGGREGATED CHARTS (Added for PS2)
-- ==========================================

-- 8. Chart: Channel Winners (Required: "Which acquisition channel produces highest repeat rate?")
DROP VIEW IF EXISTS v_ps2_channel_chart CASCADE;
CREATE OR REPLACE VIEW v_ps2_channel_chart AS
WITH first_orders AS (
    SELECT customer_id, channel, MIN(order_date) as first_order_date
    FROM orders
    GROUP BY 1, 2
),
cohort_repeaters AS (
    SELECT 
        f.customer_id,
        f.first_order_date,
        f.channel,
        MAX(CASE 
            WHEN (o.order_date - f.first_order_date) > 0 
             AND (o.order_date - f.first_order_date) <= 90 
            THEN 1 ELSE 0 
        END) as is_90day_repeater
    FROM first_orders f
    LEFT JOIN orders o ON f.customer_id = o.customer_id
    WHERE f.first_order_date BETWEEN '2023-10-01' AND '2023-12-31' -- Q4 Cohort Only
    GROUP BY 1, 2, 3
)
SELECT 
    CASE WHEN channel = 'PaidSearch' THEN 'Paid Search' ELSE channel END as channel_name,
    AVG(is_90day_repeater) as repeat_rate_q4
FROM cohort_repeaters
GROUP BY 1;

-- 9. Chart: Fashion Value Strategy (Required: "Lift in Q1 AOV compared to Electronics")
DROP VIEW IF EXISTS v_ps2_lift_chart CASCADE;
CREATE OR REPLACE VIEW v_ps2_lift_chart AS
WITH first_orders AS (
    -- Identify Q4 First Orders for Segmentation
    SELECT customer_id, min(order_date) as first_order_date
    FROM orders
    GROUP BY 1
    HAVING min(order_date) BETWEEN '2023-10-01' AND '2023-12-31'
),
user_segments AS (
    SELECT 
        f.customer_id,
        CASE 
            WHEN SUM(CASE WHEN o.category = 'Fashion' THEN o.revenue ELSE 0 END) > 
                 SUM(CASE WHEN o.category = 'Electronics' THEN o.revenue ELSE 0 END) THEN 'Fashion-Heavy'
            WHEN SUM(CASE WHEN o.category = 'Electronics' THEN o.revenue ELSE 0 END) > 0 THEN 'Electronics-Only'
            ELSE 'Other'
        END as segment
    FROM first_orders f
    JOIN orders o ON f.customer_id = o.customer_id
    WHERE o.order_date BETWEEN '2023-10-01' AND '2023-12-31' -- Segmentation based on Q4 spend
    GROUP BY 1
),
period_aovs AS (
    SELECT 
        s.customer_id,
        s.segment,
        AVG(CASE WHEN o.order_date BETWEEN '2023-10-01' AND '2023-12-31' THEN o.revenue END) as q4_cust_aov,
        AVG(CASE WHEN o.order_date BETWEEN '2024-01-01' AND '2024-03-31' THEN o.revenue END) as q1_cust_aov
    FROM user_segments s
    JOIN orders o ON s.customer_id = o.customer_id
    GROUP BY 1, 2
)
SELECT 
    segment,
    AVG(q4_cust_aov) as q4_avg_aov,
    AVG(q1_cust_aov) as q1_avg_aov,
    (AVG(q1_cust_aov) - AVG(q4_cust_aov)) / NULLIF(AVG(q4_cust_aov), 0) as aov_lift_pct
FROM period_aovs
GROUP BY 1;

-- ==========================================
-- FINAL FIX: CONSOLIDATED PS3 VIEWS (Email Incrementality)
-- ==========================================

-- 10. Analytics: PS3 Weekly Suppression (Email Blast Logic)
-- Purpose: Pre-calculating "Blast Weeks" so Power BI can slice Organic/Total revenue by week type.
-- Senior Tip: We use GREATEST to ensure the week-start doesn't "leak" into 2022 due to Jan 1st being a Sunday.
DROP VIEW IF EXISTS v_ps3_weekly_suppression CASCADE;
CREATE OR REPLACE VIEW v_ps3_weekly_suppression AS
WITH weekly_metrics AS (
    SELECT 
        GREATEST('2023-01-01'::DATE, DATE_TRUNC('week', order_date))::DATE as order_week,
        SUM(revenue) as total_rev,
        SUM(CASE WHEN channel = 'Email' THEN revenue ELSE 0 END) as email_rev,
        SUM(CASE WHEN channel = 'Organic' THEN revenue ELSE 0 END) as organic_rev
    FROM orders
    GROUP BY 1
),
avg_email AS (
    SELECT AVG(email_rev) as mean_email_rev FROM weekly_metrics
)
SELECT 
    w.*,
    CASE 
        WHEN w.email_rev > 1.2 * (SELECT mean_email_rev FROM avg_email) THEN 'Email Blast' 
        ELSE 'Normal' 
    END as week_type
FROM weekly_metrics w;

-- 11. Analytics: PS3 User Overlap (Cannibalization Logic)
-- Purpose: Pre-calculating user-level flags for Reactivation vs Cannibalization.
-- This allows us to create the "Truth Waterfall" in Power BI.
DROP VIEW IF EXISTS v_ps3_user_overlap CASCADE;
CREATE OR REPLACE VIEW v_ps3_user_overlap AS
WITH user_anchors AS (
    SELECT customer_id, signup_date, channel as signup_channel
    FROM customers
),
labeled_orders AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_date,
        o.channel as order_channel,
        o.revenue,
        u.signup_date,
        u.signup_channel,
        (o.order_date - u.signup_date) as days_since_signup
    FROM orders o
    JOIN user_anchors u ON o.customer_id = u.customer_id
)
SELECT 
    *,
    CASE 
        WHEN order_channel = 'Email' AND days_since_signup > 30 THEN 1 
        ELSE 0 
    END as is_reactivation,
    CASE 
        WHEN order_channel = 'Email' AND days_since_signup <= 7 AND signup_channel = 'Organic' THEN 1 
        ELSE 0 
    END as is_cannibalized,
    -- NEW: Human-readable segment for Chart 3
    CASE 
        WHEN order_channel = 'Email' AND days_since_signup > 30 THEN 'True Reactivation'
        WHEN order_channel = 'Email' AND days_since_signup <= 7 AND signup_channel = 'Organic' THEN 'Cannibalized Organic'
        WHEN order_channel = 'Email' THEN 'Standard Email Order'
        ELSE 'Other Channel'
    END as interaction_type
FROM labeled_orders;

-- 12. Technical Bridge: PS3 Waterfall Labels
-- Purpose: Waterfall charts need a PHYSICAL COLUMN for the X-axis. 
DROP VIEW IF EXISTS v_ps3_waterfall_bridge CASCADE;
CREATE OR REPLACE VIEW v_ps3_waterfall_bridge AS
SELECT 'Reported Revenue' AS step, 1 AS sort_order
UNION ALL
SELECT 'Cannibalized Demand' AS step, 2 AS sort_order;

-- Audit Check
SELECT * FROM v_ps3_weekly_suppression LIMIT 5;
SELECT * FROM v_ps3_user_overlap LIMIT 5;
SELECT * FROM v_ps3_waterfall_bridge;
