-- E-Commerce Sales Analysis Project (Synthetic practice data)
-- MySQL Workbench compatible.
-- The CSV file is separate: import ecommerce_sales_5000.csv using Table Data Import Wizard.
-- IMPORTANT: This script creates the database/table and analysis queries; it does not auto-load the CSV.

CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

DROP TABLE IF EXISTS sales_raw;
CREATE TABLE sales_raw (
    order_id VARCHAR(20),
    order_date DATE,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(12,2),
    discount_pct DECIMAL(5,2),
    sales_amount DECIMAL(12,2),
    cost_amount DECIMAL(12,2),
    profit_amount DECIMAL(12,2),
    city VARCHAR(80),
    state VARCHAR(80),
    sales_channel VARCHAR(40),
    payment_method VARCHAR(40),
    order_status VARCHAR(30),
    customer_segment VARCHAR(30)
);

-- After importing CSV into sales_raw, run these queries:

-- 1. Check total records
SELECT COUNT(*) AS total_rows FROM sales_raw;

-- 2. Preview records
SELECT * FROM sales_raw LIMIT 20;

-- 3. Check duplicate order IDs
SELECT order_id, COUNT(*) AS row_count
FROM sales_raw
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 4. Check nulls in important columns
SELECT
    SUM(order_id IS NULL) AS null_order_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(sales_amount IS NULL) AS null_sales_amount
FROM sales_raw;

-- 5. Overall business KPIs
SELECT
    COUNT(*) AS order_lines,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(sales_amount), 2) AS total_sales,
    ROUND(SUM(profit_amount), 2) AS total_profit,
    ROUND(AVG(sales_amount), 2) AS average_line_value
FROM sales_raw;

-- 6. Sales by category
SELECT category,
       ROUND(SUM(sales_amount), 2) AS total_sales,
       ROUND(SUM(profit_amount), 2) AS total_profit
FROM sales_raw
GROUP BY category
ORDER BY total_sales DESC;

-- 7. Top 10 products by sales
SELECT product_name,
       SUM(quantity) AS units_sold,
       ROUND(SUM(sales_amount), 2) AS total_sales
FROM sales_raw
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- 8. State-wise performance
SELECT state,
       COUNT(*) AS order_lines,
       ROUND(SUM(sales_amount), 2) AS total_sales,
       ROUND(SUM(profit_amount), 2) AS total_profit
FROM sales_raw
GROUP BY state
ORDER BY total_sales DESC;

-- 9. Monthly sales trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
       ROUND(SUM(sales_amount), 2) AS monthly_sales,
       ROUND(SUM(profit_amount), 2) AS monthly_profit
FROM sales_raw
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

-- 10. Order status breakdown
SELECT order_status,
       COUNT(*) AS order_lines,
       ROUND(SUM(sales_amount), 2) AS sales_value
FROM sales_raw
GROUP BY order_status
ORDER BY order_lines DESC;

-- 11. Sales channel analysis
SELECT sales_channel,
       COUNT(*) AS order_lines,
       ROUND(SUM(sales_amount), 2) AS total_sales
FROM sales_raw
GROUP BY sales_channel
ORDER BY total_sales DESC;

-- 12. Customer segment analysis
SELECT customer_segment,
       COUNT(DISTINCT customer_id) AS customers,
       ROUND(SUM(sales_amount), 2) AS total_sales,
       ROUND(AVG(sales_amount), 2) AS average_line_value
FROM sales_raw
GROUP BY customer_segment
ORDER BY total_sales DESC;

-- 13. CTE: monthly sales compared with previous month
WITH monthly_sales AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
           SUM(sales_amount) AS total_sales
    FROM sales_raw
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
monthly_with_previous AS (
    SELECT sales_month,
           total_sales,
           LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM monthly_sales
)
SELECT sales_month,
       ROUND(total_sales, 2) AS total_sales,
       ROUND(previous_month_sales, 2) AS previous_month_sales,
       ROUND(100 * (total_sales - previous_month_sales) / NULLIF(previous_month_sales, 0), 2) AS growth_pct
FROM monthly_with_previous
ORDER BY sales_month;

-- 14. Window function: rank products within each category
WITH product_sales AS (
    SELECT category, product_name, SUM(sales_amount) AS total_sales
    FROM sales_raw
    GROUP BY category, product_name
)
SELECT category, product_name,
       ROUND(total_sales, 2) AS total_sales,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS category_rank
FROM product_sales
ORDER BY category, category_rank;

-- 15. Profit margin by category
SELECT category,
       ROUND(SUM(sales_amount), 2) AS total_sales,
       ROUND(SUM(profit_amount), 2) AS total_profit,
       ROUND(100 * SUM(profit_amount) / NULLIF(SUM(sales_amount), 0), 2) AS profit_margin_pct
FROM sales_raw
GROUP BY category
ORDER BY profit_margin_pct DESC;

-- 16. High-value customers
SELECT customer_id,
       COUNT(*) AS order_lines,
       ROUND(SUM(sales_amount), 2) AS customer_sales
FROM sales_raw
GROUP BY customer_id
HAVING SUM(sales_amount) >= 15000
ORDER BY customer_sales DESC;

-- 17. Return/cancel share
SELECT
    ROUND(100 * SUM(order_status = 'Returned') / COUNT(*), 2) AS returned_pct,
    ROUND(100 * SUM(order_status = 'Cancelled') / COUNT(*), 2) AS cancelled_pct
FROM sales_raw;

-- 18. Data quality: impossible/negative values
SELECT *
FROM sales_raw
WHERE quantity IS NULL OR quantity <= 0
   OR unit_price < 0
   OR sales_amount < 0
   OR profit_amount IS NULL;

-- 19. Create cleaned table (basic rule-based cleaning; keeps rows with essential fields)
DROP TABLE IF EXISTS sales_clean;
CREATE TABLE sales_clean AS
SELECT *
FROM sales_raw
WHERE order_id IS NOT NULL
  AND order_date IS NOT NULL
  AND customer_id IS NOT NULL
  AND product_id IS NOT NULL
  AND quantity > 0
  AND unit_price >= 0
  AND sales_amount >= 0;

-- 20. Compare raw vs cleaned counts
SELECT
    (SELECT COUNT(*) FROM sales_raw) AS raw_rows,
    (SELECT COUNT(*) FROM sales_clean) AS clean_rows;
