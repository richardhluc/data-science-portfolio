/*
============================================================
Restaurant Customer Order Analysis

Business Proposition: Restaurants aim to increase revenue and 
strengthen customer loyalty by understanding order patterns, 
member behavior, and menu performance. This SQL project 
analyzes transactional, customer, and menu data to uncover 
insights that drive strategic decisions across pricing, 
promotions, and customer retention.
============================================================
*/

-- =========================================================
-- SECTION 0: CLEANUP (DROP TABLES IF THEY EXIST)
-- =========================================================

-- Normalized tables
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS meals;
DROP TABLE IF EXISTS meal_types;
DROP TABLE IF EXISTS serve_types;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS monthly_member_totals;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS restaurant_types;
DROP TABLE IF EXISTS cities;

-- Staging tables
DROP TABLE IF EXISTS staging_order_details;
DROP TABLE IF EXISTS staging_meals;
DROP TABLE IF EXISTS staging_meal_types;
DROP TABLE IF EXISTS staging_serve_types;
DROP TABLE IF EXISTS staging_orders;
DROP TABLE IF EXISTS staging_monthly_member_totals;
DROP TABLE IF EXISTS staging_members;
DROP TABLE IF EXISTS staging_restaurants;
DROP TABLE IF EXISTS staging_restaurant_types;
DROP TABLE IF EXISTS staging_cities;

-- =========================================================
-- SECTION 1: STAGING TABLES (RAW CSV IMPORT)
-- =========================================================

-- 1. Orders staging
CREATE TABLE staging_orders (
    id INT,
    date TIMESTAMP,
    hour TIME,
    member_id INT,
    restaurant_id INT,
    total_order NUMERIC(10,2)
);

-- 2. Restaurants staging
CREATE TABLE staging_restaurants (
    id INT,
    restaurant_name TEXT,
    restaurant_type_id INT,
    income_percentage NUMERIC(5,2),
    city_id INT
);

-- 3. Restaurant types staging
CREATE TABLE staging_restaurant_types (
    id INT,
    restaurant_type TEXT
);

-- 4. Cities staging
CREATE TABLE staging_cities (
    id INT,
    city TEXT
);

-- 5. Members staging
CREATE TABLE staging_members (
    id INT,
    first_name TEXT,
    surname TEXT,
    sex TEXT,
    email TEXT,
    city_id INT,
    monthly_budget NUMERIC(10,2)
);

-- 6. Monthly member totals staging
CREATE TABLE staging_monthly_member_totals (
    member_id INT,
    first_name TEXT,
    surname TEXT,
    sex TEXT,
    email TEXT,
    city TEXT,
    year INT,
    month INT,
    order_count INT,
    meals_count INT,
    monthly_budget NUMERIC(10,2),
    total_expense NUMERIC(10,2),
    balance NUMERIC(10,2),
    commission NUMERIC(10,2)
);

-- 7. Meals staging
CREATE TABLE staging_meals (
    id INT,
    restaurant_id INT,
    serve_type_id INT,
    meal_type_id INT,
    hot_cold TEXT,
    meal_name TEXT,
    price NUMERIC(10,2)
);

-- 8. Meal types staging
CREATE TABLE staging_meal_types (
    id INT,
    meal_type TEXT
);

-- 9. Serve types staging
CREATE TABLE staging_serve_types (
    id INT,
    serve_type TEXT
);

-- 10. Order details staging
CREATE TABLE staging_order_details (
    id INT,
    order_id INT,
    meal_id INT
);

-- =========================================================
-- SECTION 2: NORMALIZED TABLES
-- ---------------------------------------------------------
-- Create dimension tables first, then facts.
-- =========================================================

-- 2.1 Cities (dimension)
CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city VARCHAR(100)
);

INSERT INTO cities (city_id, city)
SELECT DISTINCT id, city
FROM staging_cities;

-- 2.2 Restaurant types (dimension)
CREATE TABLE restaurant_types (
    restaurant_type_id INT PRIMARY KEY,
    restaurant_type VARCHAR(50)
);

INSERT INTO restaurant_types (restaurant_type_id, restaurant_type)
SELECT DISTINCT id, restaurant_type
FROM staging_restaurant_types;

-- 2.3 Restaurants (dimension)
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(150),
    restaurant_type_id INT REFERENCES restaurant_types(restaurant_type_id),
    income_percentage NUMERIC(5,2),
    city_id INT REFERENCES cities(city_id)
);

INSERT INTO restaurants (restaurant_id, restaurant_name, restaurant_type_id, income_percentage, city_id)
SELECT DISTINCT
    id,
    restaurant_name,
    restaurant_type_id,
    income_percentage,
    city_id
FROM staging_restaurants;

-- 2.4 Members (dimension)
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    surname VARCHAR(100),
    sex VARCHAR(20),
    email VARCHAR(255),
    city_id INT REFERENCES cities(city_id),
    monthly_budget NUMERIC(10,2)
);

INSERT INTO members (member_id, first_name, surname, sex, email, city_id, monthly_budget)
SELECT DISTINCT
    id,
    first_name,
    surname,
    sex,
    email,
    city_id,
    monthly_budget
FROM staging_members;

-- 2.5 Orders (fact)
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date TIMESTAMP,
    hour TIME,
    member_id INT REFERENCES members(member_id),
    restaurant_id INT REFERENCES restaurants(restaurant_id),
    total_order NUMERIC(10,2)
);

INSERT INTO orders (order_id, order_date, hour, member_id, restaurant_id, total_order)
SELECT DISTINCT
    id,
    date,
    hour,
    member_id,
    restaurant_id,
    total_order
FROM staging_orders;

-- 2.6 Monthly member totals (aggregate snapshot per member-month)
CREATE TABLE monthly_member_totals (
    member_id INT REFERENCES members(member_id),
    year INT,
    month INT,
    order_count INT,
    meals_count INT,
    monthly_budget NUMERIC(10,2),
    total_expense NUMERIC(10,2),
    balance NUMERIC(10,2),
    commission NUMERIC(10,2),
    PRIMARY KEY (member_id, year, month)
);

INSERT INTO monthly_member_totals (
    member_id,
    year,
    month,
    order_count,
    meals_count,
    monthly_budget,
    total_expense,
    balance,
    commission
)
SELECT
    member_id,
    year,
    month,
    order_count,
    meals_count,
    monthly_budget,
    total_expense,
    balance,
    commission
FROM staging_monthly_member_totals;

-- 2.7 Serve types (dimension)
CREATE TABLE serve_types (
    serve_type_id INT PRIMARY KEY,
    serve_type VARCHAR(50)
);

INSERT INTO serve_types (serve_type_id, serve_type)
SELECT DISTINCT id, serve_type
FROM staging_serve_types;

-- 2.8 Meal types (dimension)
CREATE TABLE meal_types (
    meal_type_id INT PRIMARY KEY,
    meal_type VARCHAR(50)
);

INSERT INTO meal_types (meal_type_id, meal_type)
SELECT DISTINCT id, meal_type
FROM staging_meal_types;

-- 2.9 Meals (dimension)
CREATE TABLE meals (
    meal_id INT PRIMARY KEY,
    restaurant_id INT REFERENCES restaurants(restaurant_id),
    serve_type_id INT REFERENCES serve_types(serve_type_id),
    meal_type_id INT REFERENCES meal_types(meal_type_id),
    hot_cold VARCHAR(20),
    meal_name VARCHAR(200),
    price NUMERIC(10,2)
);

INSERT INTO meals (meal_id, restaurant_id, serve_type_id, meal_type_id, hot_cold, meal_name, price)
SELECT DISTINCT
    id,
    restaurant_id,
    serve_type_id,
    meal_type_id,
    hot_cold,
    meal_name,
    price
FROM staging_meals;

-- 2.10 Order details (fact line items)
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    meal_id INT REFERENCES meals(meal_id)
);

INSERT INTO order_details (order_detail_id, order_id, meal_id)
SELECT DISTINCT
    id,
    order_id,
    meal_id
FROM staging_order_details;

-- =========================================================
-- SECTION 3: DATA QUALITY CHECKS / BASIC EDA
-- =========================================================

-- 3.1 Orders null check
SELECT
    COUNT(*) AS total_orders,
    COUNT(order_date) AS non_null_order_date,
    COUNT(total_order) AS non_null_total_order
FROM orders;

-- 3.2 Orphaned FKs: orders without valid member or restaurant
SELECT o.order_id
FROM orders o
LEFT JOIN members m ON o.member_id = m.member_id
LEFT JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE m.member_id IS NULL
   OR r.restaurant_id IS NULL
LIMIT 10;

-- 3.3 Top 5 restaurants by total revenue (sanity + business insight)
SELECT
    r.restaurant_name,
    ROUND(SUM(o.total_order), 2) AS revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY revenue DESC
LIMIT 5;

-- 3.4 Summary statistics for order amounts (in USD) 
SELECT
    MIN(total_order) AS min_order_value,
    MAX(total_order) AS max_order_value,
    ROUND(AVG(total_order), 2) AS avg_order_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_order) AS median_order_value
FROM orders;

-- 3.5: Per-restaurant order value summary
SELECT
    r.restaurant_name,
    COUNT(*) AS num_orders,
    MIN(o.total_order) AS min_order_value,
    MAX(o.total_order) AS max_order_value,
    ROUND(AVG(o.total_order), 2) AS avg_order_value
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY avg_order_value DESC;

-- =========================================================
-- SECTION 4: BUSINESS OBJECTIVE 1 – REVENUE & PEAK TIMES
-- =========================================================

-- 4.1 Revenue per restaurant
SELECT
    r.restaurant_name,
    SUM(o.total_order) AS total_revenue,
    COUNT(*) AS total_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC
LIMIT 15;

-- 4.2 Revenue by restaurant type
SELECT
    rt.restaurant_type,
    SUM(o.total_order) AS total_revenue,
    COUNT(*) AS total_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
JOIN restaurant_types rt ON r.restaurant_type_id = rt.restaurant_type_id
GROUP BY rt.restaurant_type
ORDER BY total_revenue DESC;

-- 4.3 Top 25 weekday/hour combinations (peak ordering times)
SELECT
    TO_CHAR(order_date, 'FMDay') AS weekday_name,
    TO_CHAR(hour, 'HH12:MI AM') AS hour_am_pm,
    COUNT(*) AS num_orders
FROM orders
GROUP BY
    TO_CHAR(order_date, 'FMDay'),
    TO_CHAR(hour, 'HH12:MI AM')
ORDER BY num_orders DESC
LIMIT 25;

-- 4.4 Monthly trends: active members, orders, revenue, AOV
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    COUNT(DISTINCT o.member_id) AS active_members,
    COUNT(*) AS total_orders,
    ROUND(SUM(o.total_order), 2) AS total_revenue,
    ROUND(SUM(o.total_order) / COUNT(*), 2) AS avg_order_value
FROM orders o
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- =========================================================
-- SECTION 5: BUSINESS OBJECTIVE 2 – MEMBER SEGMENTATION (RFM)
-- =========================================================

-- 5.1 Top 10 high-value members (by monetary)
WITH max_date AS (
    SELECT MAX(order_date) AS max_order_date
    FROM orders
),
member_metrics AS (
    SELECT
        o.member_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(*) AS frequency,
        SUM(o.total_order) AS monetary
    FROM orders o
    GROUP BY o.member_id
),
rfm AS (
    SELECT
        m.member_id,
        mm.last_order_date,
        EXTRACT(DAY FROM (md.max_order_date - mm.last_order_date)) AS recency_days,
        mm.frequency,
        mm.monetary
    FROM member_metrics mm
    CROSS JOIN max_date md
    JOIN members m ON mm.member_id = m.member_id
)
SELECT
    member_id,
    last_order_date,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary
FROM rfm
ORDER BY monetary DESC
LIMIT 10;

-- 5.2 Members at risk of churn (>= 1 day since last order)
WITH max_date AS (
    SELECT MAX(order_date) AS max_order_date
    FROM orders
),
member_metrics AS (
    SELECT
        o.member_id,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    GROUP BY o.member_id
)
SELECT
    mm.member_id,
    mm.last_order_date,
    EXTRACT(DAY FROM (md.max_order_date - mm.last_order_date)) AS days_since_last_order
FROM member_metrics mm
CROSS JOIN max_date md
WHERE EXTRACT(DAY FROM (md.max_order_date - mm.last_order_date)) >= 1
ORDER BY days_since_last_order DESC
LIMIT 10;

-- 5.3 Simple RFM scoring with quintiles (1–5)
WITH max_date AS (
    SELECT MAX(order_date) AS max_order_date
    FROM orders
),
member_metrics AS (
    SELECT
        o.member_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(*) AS frequency,
        SUM(o.total_order) AS monetary
    FROM orders o
    GROUP BY o.member_id
),
base AS (
    SELECT
        member_id,
        EXTRACT(DAY FROM (md.max_order_date - last_order_date)) AS recency_days,
        frequency,
        monetary
    FROM member_metrics
    CROSS JOIN max_date md
),
scored AS (
    SELECT
        member_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC)    AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary DESC)     AS monetary_score
    FROM base
)
SELECT
    member_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score AS rfm_total_score
FROM scored
ORDER BY rfm_total_score DESC
LIMIT 20;

-- =========================================================
-- SECTION 6: BUSINESS OBJECTIVE 3 – MENU PERFORMANCE & COMBOS
-- =========================================================

-- 6.1 Top-selling meals by revenue
-- Assumes each order_details row represents quantity = 1 for that meal.
SELECT
    m.meal_name,
    COUNT(od.order_id) AS times_ordered,
    SUM(m.price) AS revenue
FROM order_details od
JOIN meals m ON od.meal_id = m.meal_id
GROUP BY m.meal_name
ORDER BY revenue DESC
LIMIT 10;

-- 6.2 Frequently bought together meal pairs (basket analysis)
WITH item_pairs AS (
    SELECT
        od1.meal_id AS item1,
        od2.meal_id AS item2,
        COUNT(DISTINCT od1.order_id) AS orders_together
    FROM order_details od1
    JOIN order_details od2
      ON od1.order_id = od2.order_id
     AND od1.meal_id < od2.meal_id
    GROUP BY item1, item2
)
SELECT
    m1.meal_name AS item1_name,
    m2.meal_name AS item2_name,
    ip.orders_together
FROM item_pairs ip
JOIN meals m1 ON ip.item1 = m1.meal_id
JOIN meals m2 ON ip.item2 = m2.meal_id
ORDER BY ip.orders_together DESC
LIMIT 10;
