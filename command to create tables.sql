-- 1. Customers Table
DROP TABLE IF EXISTS public.customers;
CREATE TABLE public.customers (
    customer_id INTEGER PRIMARY KEY,
    signup_date DATE,
    country VARCHAR(10),
    channel VARCHAR(50)
);
-- 2. Orders Table
DROP TABLE IF EXISTS public.orders;
CREATE TABLE public.orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    product_id INTEGER,
    order_date DATE,
    category VARCHAR(50),
    channel VARCHAR(50),
    quantity INTEGER,
    base_price DECIMAL(10, 2),
    revenue DECIMAL(10, 2)
);
-- 3. Marketing Spend Table
DROP TABLE IF EXISTS public.marketing_spend;
CREATE TABLE public.marketing_spend (
    date DATE,
    channel VARCHAR(50),
    spend DECIMAL(10, 2)
);
-- 4. Products Table
DROP TABLE IF EXISTS public.products;
CREATE TABLE public.products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    base_price DECIMAL(10, 2),
    margin DECIMAL(5, 2)
);
-- 5. Website Sessions Table
DROP TABLE IF EXISTS public.website_sessions;
CREATE TABLE public.website_sessions (
    date DATE,
    channel VARCHAR(50),
    sessions INTEGER
);