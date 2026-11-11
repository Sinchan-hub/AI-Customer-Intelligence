CREATE DATABASE olist_customer_intelligence;

USE olist_customer_intelligence;

SELECT DATABASE();

CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

DESCRIBE customers;

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

DESCRIBE orders;

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

DESCRIBE order_items;

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

DESCRIBE order_payments;

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

DESCRIBE products;

CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

DESCRIBE sellers;

CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

DESCRIBE order_reviews;

CREATE TABLE category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

DESCRIBE category_translation;

SELECT COUNT(*) AS total_customers
FROM customers;

TRUNCATE TABLE customers;

SELECT COUNT(*) FROM customers;

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'local_infile';

TRUNCATE TABLE customers;

SELECT COUNT(*) AS total_customers
FROM customers;

TRUNCATE TABLE customers;

SELECT COUNT(*) FROM customers;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
);

SELECT COUNT(*) FROM customers;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
);

SELECT COUNT(*) AS total_orders
FROM orders;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
);

SELECT COUNT(*) AS total_order_items
FROM order_items;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
);

SELECT COUNT(*) AS total_payments
FROM order_payments;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
);

SELECT COUNT(*) AS total_products
FROM products;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
);

SELECT COUNT(*) AS total_sellers
FROM sellers;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
);

SELECT COUNT(*) AS total_reviews
FROM order_reviews;

LOAD DATA LOCAL INFILE 'C:/Users/Sinchan/Downloads/AI_Customer_Intelligence/datasets/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_category_name,
    product_category_name_english
);

SELECT COUNT(*) AS total_categories
FROM category_translation;

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;

-- How many orders are in each order status?
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- How much revenue did the business generate each month from delivered orders?
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM orders o
JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value
    FROM order_payments
    GROUP BY order_id
) p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

-- Which product categories generate the highest sales revenue?
SELECT
    COALESCE(ct.product_category_name_english, 'Unknown') AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;

-- Which cities have the highest number of customers?
SELECT
    customer_city,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;

-- Which payment methods are most commonly used by customers?
SELECT
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;

-- Average customer review score by product category
SELECT
    COALESCE(ct.product_category_name_english, 'Unknown') AS category,
    ROUND(AVG(r.review_score), 2) AS average_rating,
    COUNT(r.review_id) AS total_reviews
FROM order_reviews r
JOIN orders o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
HAVING COUNT(r.review_id) >= 50
ORDER BY average_rating DESC
LIMIT 10;

-- Top 10 customers based on total spending
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.total_payment), 2) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY order_id
) p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 10;

-- Compare actual delivery date with estimated delivery date
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status;

-- Calculate average delivery time in days
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ), 2
    ) AS average_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
  
-- Check duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Find orders without a matching customer
SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check missing values in important order columns
SELECT
    COUNT(*) AS total_orders,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_purchase_timestamp IS NULL) AS missing_purchase_date,
    SUM(order_status IS NULL) AS missing_order_status
FROM orders;

-- Top 10 sellers by revenue
SELECT
    s.seller_id,
    s.seller_city,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city
ORDER BY total_revenue DESC
LIMIT 10;

CREATE INDEX idx_sellers_seller_id
ON sellers(seller_id);

SELECT 1;

-- Top 10 sellers by revenue
SELECT
    s.seller_id,
    s.seller_city,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city
ORDER BY total_revenue DESC
LIMIT 10;

SHOW VARIABLES LIKE 'wait_timeout';

SHOW INDEX FROM order_items;

SHOW TABLE STATUS LIKE 'order_items';

CREATE INDEX idx_order_items_seller_id
ON order_items(seller_id);

CREATE INDEX idx_orders_order_id
ON orders(order_id);

-- Top 10 sellers by revenue
SELECT
    s.seller_id,
    s.seller_city,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city
ORDER BY total_revenue DESC
LIMIT 10;

-- Calculate Average Order Value (AOV)
SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(payment_value) AS order_total
    FROM order_payments
    GROUP BY order_id
) p
JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Monthly order count and growth percentage
WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
)
SELECT
    order_month,
    total_orders,
    LAG(total_orders) OVER (ORDER BY order_month) AS previous_month_orders,
    ROUND(
        (
            total_orders - LAG(total_orders) OVER (ORDER BY order_month)
        ) * 100.0 /
        NULLIF(LAG(total_orders) OVER (ORDER BY order_month), 0),
        2
    ) AS growth_percentage
FROM monthly_orders
ORDER BY order_month;

-- Analyze one-time and repeat customers
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM customer_orders
GROUP BY customer_type;

-- Revenue contribution by payment method
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(
        SUM(payment_value) * 100.0 /
        (SELECT SUM(payment_value) FROM order_payments),
        2
    ) AS revenue_percentage
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;