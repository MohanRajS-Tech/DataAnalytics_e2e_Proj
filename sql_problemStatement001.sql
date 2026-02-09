"""
Problem Statement - 1
Electronics accounts for 55% of revenue but has the lowest margins (15-18%), 
whereas Fashion contributes 21% with margins up to 60%. Assuming constant conversion 
elasticity, how would a $50k reallocation of 'Paid Search' budget from Electronics to Fashion 
impact total net profit, and at what point does Fashion reach demand saturation?
"""

select * from products
select * from orders
select * from marketing_spend
select channel,sum(spend) from marketing_spend
group by channel
select channel,sum(revenue) from orders
group by channel

UPDATE orders
SET channel = 'Paid Search'
WHERE channel = 'PaidSearch';

select category,count(order_id),sum(quantity),sum(revenue) from orders
group by category

----------

--combining tables to fuse margin and revenue to get profit
--in orders- order_id,customer_id,product_id,order_date,category,channel,quantity,base_price,revenue
--in products- product_id,product_name,category,base_price,margin

select o.order_id, 
    o.order_date, 
    o.channel, 
    p.category, 
    o.revenue,
    p.margin
from orders as o
join products as p
on o.product_id = p.product_id

--Getting the net profit

SELECT 
    o.order_date, 
    o.channel, 
    p.category, 
    SUM(o.revenue) AS daily_revenue,
    SUM(o.revenue * p.margin) AS daily_net_profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.channel = 'Paid Search'
GROUP BY o.order_date, o.channel, p.category;

--finding the total revenue per category and splitting the marketing spend.
SELECT category, SUM(revenue) as cat_revenue
FROM orders
WHERE channel = 'Paid Search'
GROUP BY 1;
--Total marketing spend
SELECT SUM(spend) as total_ps_spend 
FROM marketing_spend 
WHERE channel = 'Paid Search';
--assigning marketing spent weight to each category based on revenue
SELECT 
    category,
    SUM(revenue) AS cat_revenue,
    ROUND((SUM(revenue) / SUM(SUM(revenue)) OVER ()) * 100, 2) || '%' AS revenue_share_pct
FROM orders
WHERE channel = 'Paid Search'
GROUP BY 1;
--finding how much money was spent for each category
WITH cat_revenue AS (
    SELECT category, SUM(revenue) as revenue
    FROM orders WHERE channel = 'Paid Search' GROUP BY 1
),
total_spend AS (
    SELECT SUM(spend) as spend
    FROM marketing_spend WHERE channel = 'Paid Search'
)
SELECT 
    c.category,
    ROUND((c.revenue / (SELECT SUM(revenue) FROM cat_revenue)) * (SELECT spend FROM total_spend),2) as attributed_spend
FROM cat_revenue c;





--"GROUP BY" columns must always match the columns in your SELECT list that aren't being summed. 
--If you select it without a sum/count, you MUST group by it.

--Combining with marketing spend table to get ROAS

-- Part A: The "Temporary Table" of Sales
WITH daily_sales AS (
    SELECT 
        o.order_date, 
        o.channel, 
        p.category, 
        SUM(o.revenue) AS revenue,
        SUM(o.revenue * p.margin) AS profit
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.channel = 'Paid Search'
    GROUP BY 1, 2, 3
)
-- Part B: Joining Sales to Marketing Spend
SELECT 
    s.category,
    SUM(s.revenue) AS total_revenue,
    SUM(m.spend) AS total_spend,
    -- The Final ROAS Calculation:
    SUM(s.revenue) / SUM(m.spend) AS roas
FROM daily_sales s
JOIN marketing_spend m ON s.order_date = m.date AND s.channel = m.channel
GROUP BY 1;

------------------------------------------------

--Using Revenue-Share Attribution to divide the marketing spend to different category
--to compare ROAS and POAS

WITH totals AS (
    -- 1. Calculate Grand Totals for Paid Search
    SELECT 
        p.category,
        SUM(o.revenue) as cat_revenue,
        SUM(o.revenue * p.margin) as cat_profit
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE channel = 'Paid Search'
    GROUP BY 1
),
overall_spend AS (
    -- 2. Get the actual TOTAL spend for Paid Search (No Join!)
    SELECT SUM(spend) as actual_total_spend 
    FROM marketing_spend 
    WHERE channel = 'Paid Search'
)

SELECT 
    t.category,
    t.cat_revenue,
    -- Step 3: Attribute the budget based on the 55% / 21% logic
    (t.cat_revenue / (SELECT SUM(cat_revenue) FROM totals)) * (SELECT actual_total_spend FROM overall_spend) as attributed_spend,
    -- Now calculate the REAL ROAS/POAS
    t.cat_revenue / ((t.cat_revenue / (SELECT SUM(cat_revenue) FROM totals)) * (SELECT actual_total_spend FROM overall_spend)) as real_roas,
    t.cat_profit / ((t.cat_revenue / (SELECT SUM(cat_revenue) FROM totals)) * (SELECT actual_total_spend FROM overall_spend)) as real_poas
FROM totals t;

--------------------------------------------------
--To find the fashion saturation point
--looking into the monthy spend and POAS and finding the spend where the POAS is the highest.

-- Part A: Daily sales by Category and Month
WITH 
monthly_sales AS (
    SELECT 
        DATE(DATE_TRUNC('month', o.order_date)) AS month,
        p.category,
        SUM(o.revenue) AS revenue,
        SUM(o.revenue * p.margin) AS net_profit
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.channel = 'Paid Search'
    GROUP BY 1, 2
),

-- Part B: Total Paid Search Spend by Month (Total company spend)
monthly_spend AS (
    SELECT 
        DATE_TRUNC('month', date) AS month,
        SUM(spend) AS total_spend
    FROM marketing_spend
    WHERE channel = 'Paid Search'
    GROUP BY 1
)

-- Part C: Bringing it all together
SELECT
    s.month,
    s.revenue AS fashion_rev,
    -- Step D: Attribute monthly spend to Fashion based on its share of THAT month's revenue
    -- (We use subqueries to get the total revenue for all categories in that specific month)
    ROUND((s.revenue / (SELECT SUM(revenue) FROM monthly_sales WHERE month = s.month)) * m.total_spend,2) AS fashion_spend,
    -- Calculate POAS for Fashion for that specific month
    ROUND(s.net_profit / ((s.revenue / (SELECT SUM(revenue) FROM monthly_sales WHERE month = s.month)) * m.total_spend),3) AS monthly_poas
FROM monthly_sales s
JOIN monthly_spend m ON s.month = m.month
WHERE s.category = 'Fashion'
ORDER BY monthly_poas DESC;