"""
Problem Statement - 2
Revenue consistently drops by ~50% from Q4 to Q1. 
Which acquisition channel produces the highest 90-day repeat rate for Q4 cohorts, 
and would a cross-category 'January Reactivation' campaign targeting Fashion-heavy buyers 
provide a statistically significant lift in Q1 AOV compared to Electronics-only buyers?
"""

select * from customers
select * from products
select category,count(*) from products group by category

--Updating PaidSearch to Paid Search
UPDATE customers
SET channel = 'Paid Search'
WHERE channel = 'PaidSearch';

----------
--Verifing the Problem Statement

SELECT 
    CASE 
        WHEN order_date BETWEEN '2023-10-01' AND '2023-12-31' THEN 'Q4 2023 (Holiday)'
        WHEN order_date BETWEEN '2024-01-01' AND '2024-03-31' THEN 'Q1 2024 (Post-Holiday)'
    END as seasonal_period,
    ROUND(SUM(o.revenue), 2) as total_revenue,
    ROUND(SUM(o.revenue * p.margin), 2) as total_net_profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.order_date BETWEEN '2023-10-01' AND '2024-03-31'
GROUP BY 1
ORDER BY 1 DESC;

----------

--To see how many customers came in during Q4 and by which channel
SELECT 
    channel, 
    COUNT(customer_id) as total_customers
FROM customers
WHERE signup_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY 1;

--To see everything they ever bought
SELECT c.customer_id,c.signup_date,c.channel, o.order_id, o.order_date
FROM customers AS c
JOIN orders o ON c.customer_id = o.customer_id
WHERE signup_date BETWEEN '2023-10-01' AND '2023-12-31';

----------

--To see how many of those people were repeat customers
--They are repeat customers if they place a second order within 90 days of their first purchase.
--creating a temp table as "loyalty List" to be used for next step

DROP TABLE loyalty_list
CREATE TEMP TABLE loyalty_list AS
WITH first_orders AS (
    SELECT customer_id, MIN(order_date) as first_purchase_date
    FROM orders
    GROUP BY 1
),
repeat_orders AS (
    SELECT o.customer_id, MIN(o.order_date) as second_purchase_date
    FROM orders o
    JOIN first_orders f ON o.customer_id = f.customer_id
    WHERE o.order_date > f.first_purchase_date
    GROUP BY 1
)
SELECT 
    c.channel,
    f.customer_id,
    CASE 
        WHEN (r.second_purchase_date - f.first_purchase_date) <= 90 THEN 1 
        ELSE 0 
    END AS is_90day_repeater
FROM first_orders f
JOIN customers c ON f.customer_id = c.customer_id
LEFT JOIN repeat_orders r ON f.customer_id = r.customer_id
WHERE c.signup_date BETWEEN '2023-10-01' AND '2023-12-31';

----------

--To get the count of repeat customers

SELECT 
    channel,
    SUM(is_90day_repeater) as repeat_customers,
    COUNT(*) as total_customers,
    ROUND((SUM(is_90day_repeater) * 100.0 / COUNT(*)), 2) as repeat_rate_pct
FROM loyalty_list
GROUP BY 1
ORDER BY repeat_rate_pct DESC;

----------

--Checking the personality of Q4 buyers
--to see how many customers are 'Fashion Heavy' (fashion spend > electronic spend) and 
--'Electronics Only' 
DROP TABLE user_segments
CREATE TEMP TABLE user_segments AS
SELECT 
    customer_id,
    CASE 
        WHEN SUM(CASE WHEN category = 'Fashion' THEN revenue ELSE 0 END) > 
             SUM(CASE WHEN category = 'Electronics' THEN revenue ELSE 0 END) THEN 'Fashion-heavy'
        WHEN SUM(CASE WHEN category = 'Electronics' THEN revenue ELSE 0 END) > 0 AND 
             SUM(CASE WHEN category = 'Fashion' THEN revenue ELSE 0 END) = 0 THEN 'Electronics-only'
        ELSE 'Mixed/Other'
    END as user_segment
FROM orders
WHERE order_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY 1;

--creating a temp table to know AOV during Q4 for fashion heavy and electronics only users

DROP TABLE q4_baselines
CREATE TEMP TABLE q4_baselines AS
SELECT 
    s.user_segment,
    ROUND(AVG(o.revenue), 2) as q4_aov
FROM user_segments s
JOIN orders o ON s.customer_id = o.customer_id
WHERE o.order_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY 1;

	
--to find the Q1 AOV 

CREATE TEMP TABLE q1_results AS
SELECT 
    s.user_segment,
    ROUND(AVG(o.revenue), 2) as q1_aov
FROM user_segments s
JOIN orders o ON s.customer_id = o.customer_id
WHERE o.order_date BETWEEN '2024-01-01' AND '2024-02-28'
GROUP BY 1;

--comparing Q1 to Q4 to identify the lift 

SELECT 
    q4.user_segment,
    q4.q4_aov,
    q1.q1_aov,
    ROUND(((q1.q1_aov - q4.q4_aov) / q4.q4_aov) * 100.0, 2) as pct_lift
FROM q4_baselines q4
JOIN q1_results q1 ON q4.user_segment = q1.user_segment
ORDER BY pct_lift DESC;


