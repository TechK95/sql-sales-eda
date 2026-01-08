-- =====================================================
-- SALES DATA EXPLORATORY DATA ANALYSIS (EDA)
-- =====================================================
-- Purpose:
-- End-to-end SQL analysis of sales, customers, and products
-- including data preparation, validation, and business insights
-- =====================================================


-- =====================================================
-- 1. DATA PREPARATION & CLEANING
-- =====================================================

-- Rename columns for consistency and usability
ALTER TABLE products
CHANGE `Product Name` product_name VARCHAR(255);

ALTER TABLE products
CHANGE `Unit Price USD` unit_price_usd VARCHAR(255);

ALTER TABLE sales
CHANGE `Order Number` order_number VARCHAR(255);

ALTER TABLE customers
CHANGE `NAME` full_name VARCHAR(255);

-- Disable safe updates for data cleaning
SET SQL_SAFE_UPDATES = 0;

-- Convert order date to DATE format
UPDATE sales
SET `Order Date` = STR_TO_DATE(`Order Date`, '%m/%d/%Y');

ALTER TABLE sales
CHANGE `Order Date` order_date DATE;

-- Convert birthday to DATE format
UPDATE customers
SET `Birthday` = STR_TO_DATE(`Birthday`, '%m/%d/%Y');

ALTER TABLE customers
CHANGE `Birthday` birthday DATE;

-- Clean and convert unit price to DECIMAL
UPDATE products
SET unit_price_usd =
REPLACE(REPLACE(unit_price_usd, '$', ''), ',', '');

ALTER TABLE products
MODIFY unit_price_usd DECIMAL(10,2);

-- Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;


-- =====================================================
-- 2. DATABASE & DIMENSION EXPLORATION
-- =====================================================

-- View all tables
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- View all columns
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

-- Geographic distribution of customers
SELECT DISTINCT country FROM customers;
SELECT DISTINCT state FROM customers;
SELECT DISTINCT city FROM customers;

-- Product hierarchy
SELECT DISTINCT category, subcategory, product_name
FROM products
ORDER BY category, subcategory, product_name;


-- =====================================================
-- 3. DATE EXPLORATION
-- =====================================================

-- First and last order dates
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM sales;

-- Sales time span (years and months)
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM sales;

-- Youngest and oldest customers
SELECT
    MIN(birthday) AS oldest_birthday,
    TIMESTAMPDIFF(YEAR, MIN(birthday), CURDATE()) AS oldest_age,
    MAX(birthday) AS youngest_birthday,
    TIMESTAMPDIFF(YEAR, MAX(birthday), CURDATE()) AS youngest_age
FROM customers;


-- =====================================================
-- 4. CORE BUSINESS METRICS
-- =====================================================

-- Total revenue
SELECT
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey;

-- Total items sold
SELECT SUM(quantity) AS total_items_sold
FROM sales;

-- Average product price
SELECT ROUND(AVG(unit_price_usd), 2) AS avg_price
FROM products;

-- Total orders
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM sales;

-- Total products
SELECT COUNT(DISTINCT productkey) AS total_products
FROM products;

-- Total customers
SELECT COUNT(DISTINCT customerkey) AS total_customers
FROM customers;

-- Customers who placed at least one order
SELECT COUNT(DISTINCT customerkey) AS customers_with_orders
FROM sales;


-- =====================================================
-- 5. KPI SUMMARY REPORT
-- =====================================================

SELECT 'Total Revenue' AS measure_name,
       ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS measure_value
FROM sales s
JOIN products p ON s.productkey = p.productkey

UNION ALL
SELECT 'Total Items Sold', SUM(quantity) FROM sales

UNION ALL
SELECT 'Average Price', ROUND(AVG(unit_price_usd), 2) FROM products

UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM sales

UNION ALL
SELECT 'Total Products', COUNT(DISTINCT productkey) FROM products

UNION ALL
SELECT 'Total Customers', COUNT(DISTINCT customerkey) FROM customers

UNION ALL
SELECT 'Customers With Orders', COUNT(DISTINCT customerkey) FROM sales;


-- =====================================================
-- 6. DATA QUALITY CHECKS
-- =====================================================

-- Validate that all sales have matching products
-- Result expected: 0 (safe to use INNER JOIN)
SELECT COUNT(*) AS unmatched_sales
FROM sales s
LEFT JOIN products p
  ON s.productkey = p.productkey
WHERE p.productkey IS NULL;


-- =====================================================
-- 7. CUSTOMER & GEOGRAPHIC ANALYSIS
-- =====================================================

-- Customers by state and city
SELECT
    state,
    city,
    COUNT(DISTINCT customerkey) AS total_customers
FROM customers
GROUP BY state, city
ORDER BY total_customers DESC;

-- Customers by gender
SELECT
    gender,
    COUNT(DISTINCT customerkey) AS total_customers
FROM customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Items sold by state
SELECT
    c.state,
    SUM(s.quantity) AS total_items_sold
FROM sales s
JOIN customers c
  ON s.customerkey = c.customerkey
GROUP BY c.state
ORDER BY total_items_sold DESC;


-- =====================================================
-- 8. PRODUCT & CATEGORY REVENUE ANALYSIS
-- =====================================================

-- Products by category
SELECT
    category,
    COUNT(DISTINCT productkey) AS total_products
FROM products
GROUP BY category
ORDER BY total_products DESC;

-- Average product cost by category
SELECT
    category,
    ROUND(AVG(unit_price_usd), 2) AS avg_cost
FROM products
GROUP BY category
ORDER BY avg_cost DESC;

-- Revenue by category
SELECT
    p.category,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Revenue by subcategory (top 5)
SELECT
    p.subcategory,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey
GROUP BY p.subcategory
ORDER BY total_revenue DESC
LIMIT 5;

-- Worst-performing subcategories
SELECT
    p.subcategory,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey
GROUP BY p.subcategory
ORDER BY total_revenue
LIMIT 5;


-- =====================================================
-- 9. PRODUCT PERFORMANCE
-- =====================================================

-- Top 5 products by revenue
SELECT
    p.product_name,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Worst 5 products by revenue
SELECT
    p.product_name,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey
GROUP BY p.product_name
ORDER BY total_revenue
LIMIT 5;


-- =====================================================
-- 10. CUSTOMER REVENUE & BEHAVIOR
-- =====================================================

-- Revenue by customer
SELECT
    c.customerkey,
    c.full_name,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN customers c
  ON s.customerkey = c.customerkey
JOIN products p
  ON s.productkey = p.productkey
GROUP BY c.customerkey, c.full_name
ORDER BY total_revenue DESC;

-- Top 10 customers by revenue
SELECT
    c.customerkey,
    c.full_name,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN customers c
  ON s.customerkey = c.customerkey
JOIN products p
  ON s.productkey = p.productkey
GROUP BY c.customerkey, c.full_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 10 customers with fewest orders
SELECT
    c.customerkey,
    c.full_name,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM sales s
JOIN customers c
  ON s.customerkey = c.customerkey
GROUP BY c.customerkey, c.full_name
ORDER BY total_orders
LIMIT 10;
