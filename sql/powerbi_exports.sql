-- Total Revenue KPIs (For PowerBI cards)
SELECT
    SUM(s.quantity * p.unit_price_usd) AS total_revenue,
    COUNT(DISTINCT s.order_number) AS total_orders,
    COUNT(DISTINCT s.customerkey) AS total_customers,
    ROUND(
        SUM(s.quantity * p.unit_price_usd) 
        / COUNT(DISTINCT s.order_number),
        2
    ) AS avg_order_value
FROM sales s
JOIN products p
    ON s.productkey = p.productkey;
    
-- Revenue by Category
SELECT
    p.category,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Revenue over time (Month & Year)
SELECT
    YEAR(s.order_date) AS order_year,
    MONTH(s.order_date) AS order_month_num,
    DATE_FORMAT(s.order_date, '%Y-%m-01') AS order_month,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
    ON s.productkey = p.productkey
GROUP BY
    order_year,
    order_month_num,
    order_month
ORDER BY order_month;

-- Top 10 customers by revenue
SELECT
	c.full_name,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN customers c
  ON s.customerkey = c.customerkey
JOIN products p
  ON s.productkey = p.productkey
GROUP BY c.full_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Revenue by State
SELECT
    c.state,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN customers c
    ON s.customerkey = c.customerkey
JOIN products p
    ON s.productkey = p.productkey
GROUP BY c.state
ORDER BY total_revenue DESC;

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

-- Bottom 5 products by revenue
SELECT
    p.product_name,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue
FROM sales s
JOIN products p
  ON s.productkey = p.productkey
GROUP BY p.product_name
ORDER BY total_revenue
LIMIT 5;

-- Revenue concentration check 
SELECT
    COUNT(DISTINCT customerkey) AS total_customers,
    COUNT(DISTINCT order_number) AS total_orders
FROM sales;
