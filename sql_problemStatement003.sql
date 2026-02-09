"""
Problem Statement 3-
Email marketing shows an exceptional ROAS (171+) but limited scale. 
Is Email driving true incremental revenue or cannibalizing Organic traffic? 
Using a time-based suppression analysis (comparing weeks with/without major blasts) and 
user-level session overlap, determine the true incremental lift of the Email channel.
"""
select * from orders
select * from customers
select distinct(channel) from orders
select * from products

--Creating a temporary table by Joining Orders table to product table to find the net profit
--and to use for future calculation

CREATE OR REPLACE VIEW public.v_order_details AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.channel, 
    o.revenue,
    -- Step 1: Bring in Margin and Calculate Profit
    (o.revenue * p.margin) AS net_profit
FROM public.orders o
JOIN public.products p ON o.product_id = p.product_id;

-----------

-- Dividing the week into Email Blast(where email rev > 1.2 avg weekly rev) and Normal
-- And the avg rev through organic channel to see if email is cannibalising on organic or not.

--  Create a Weekly Summary
WITH weekly_summary AS (
    SELECT 
        DATE_TRUNC('week', order_date) as order_week,
        SUM(net_profit) as total_profit,
        SUM(CASE WHEN channel = 'Email' THEN revenue ELSE 0 END) as email_rev,
        SUM(CASE WHEN channel = 'Organic' THEN revenue ELSE 0 END) as organic_rev
    FROM public.v_order_details
    GROUP BY 1
),
--  Identify "Blast Weeks" (e.g., Email Rev > 20% above the average)
blast_logic AS (
    SELECT 
        *,
        AVG(email_rev) OVER () as avg_email_rev
    FROM weekly_summary
)
-- Step 3: The Comparison
SELECT 
    CASE WHEN email_rev > 1.2 * avg_email_rev THEN 'Email Blast' ELSE 'Normal' END as week_type,
    COUNT(*) as num_weeks,
    ROUND(AVG(total_profit), 2) as avg_weekly_profit,
    ROUND(AVG(organic_rev), 2) as avg_weekly_organic_rev
FROM blast_logic
GROUP BY 1;


----------

-- Seeing if email is Reactivating customer or Cannibalizing on the organic sales.
-- If its within 1-7 days since the user signed up and they purchased through email, 
-- then email is likely cannibalizing on the organic revenue as they would puschased without email
-- If its more than 30 days since the user signedup , then they have purchased after email sent, 
-- then it is true Reactivation of the user.

-- Step 1: Identify "Organic" Signups and their first Email orders
WITH organic_cohort AS (
    SELECT customer_id, signup_date 
    FROM public.customers 
    WHERE channel = 'Organic'
),
user_orders AS (
    SELECT 
        o.customer_id,
        o.order_date,
        o.channel,
        c.signup_date,
        (o.order_date - c.signup_date) as days_since_signup
    FROM public.v_order_details o
    JOIN organic_cohort c ON o.customer_id = c.customer_id
)
-- Step 2: Find "Reactivation" orders
-- Example: User bought via Email after 30+ days of silence
SELECT 
    COUNT(DISTINCT customer_id) as total_organic_users,
    COUNT(DISTINCT CASE WHEN channel = 'Email' AND days_since_signup > 30 THEN customer_id END) as reactivated_via_email,
    COUNT(DISTINCT CASE WHEN channel = 'Email' AND days_since_signup <= 7 THEN customer_id END) as likely_cannibalized
FROM user_orders;
