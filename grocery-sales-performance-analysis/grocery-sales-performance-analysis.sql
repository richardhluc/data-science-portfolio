/*
============================================================
Grocery Sales Performance Analysis

Business Proposition: Grocery retailers aim to grow revenue, 
optimize product mix, and support high-performing staff and 
locations by understanding sales patterns, customer behavior,
and product performance. This SQL project analyzes 
transactional, customer, product, and employee data to uncover
insights that inform pricing strategy, merchandising decisions,
and operational efficiency.
============================================================
*/

-- =========================================================
-- SECTION 0: CLEANUP (DROP TABLES IF THEY EXIST)
-- =========================================================

-- Normalized / analytics tables
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS countries;

-- Staging tables
DROP TABLE IF EXISTS staging_sales;
DROP TABLE IF EXISTS staging_products;
DROP TABLE IF EXISTS staging_categories;
DROP TABLE IF EXISTS staging_customers;
DROP TABLE IF EXISTS staging_employees;
DROP TABLE IF EXISTS staging_cities;
DROP TABLE IF EXISTS staging_countries;

-- =========================================================
-- SECTION 1: STAGING TABLES (RAW CSV IMPORT)
-- =========================================================

-- 1.1 Sales staging
CREATE TABLE staging_sales (
    SalesID            TEXT,
    SalesPersonID      TEXT,
    CustomerID         TEXT,
    ProductID          TEXT,
    Quantity           TEXT,
    Discount           TEXT,      
    TotalPrice         TEXT,
    SalesDate          TEXT,      
    TransactionNumber  TEXT
);

-- 1.2 Employees staging
CREATE TABLE staging_employees (
    EmployeeID    TEXT,
    FirstName     TEXT,
    MiddleInitial TEXT,
    LastName      TEXT,
    BirthDate     TEXT,    
    Gender        TEXT,
    CityID        TEXT,
    HireDate      TEXT     
);

-- 1.3 Products staging
CREATE TABLE staging_products (
    ProductID    TEXT,
    ProductName  TEXT,
    Price        TEXT,
    CategoryID   TEXT,
    Class        TEXT,
    ModifyDate   TEXT,     
    Resistant    TEXT,
    IsAllergic   TEXT,
    VitalityDays TEXT      
);

-- 1.4 Countries staging
CREATE TABLE staging_countries (
    CountryID   TEXT,
    CountryName TEXT,
    CountryCode TEXT
);

-- 1.5 Cities staging
CREATE TABLE staging_cities (
    CityID    TEXT,
    CityName  TEXT,
    Zipcode   TEXT,
    CountryID TEXT
);

-- 1.6 Categories staging
CREATE TABLE staging_categories (
    CategoryID   TEXT,
    CategoryName TEXT
);

-- 1.7 Customers staging
CREATE TABLE staging_customers (
    CustomerID    TEXT,
    FirstName     TEXT,
    MiddleInitial TEXT,
    LastName      TEXT,
    CityID        TEXT,
    Address       TEXT
);

-- =========================================================
-- SECTION 2: NORMALIZED TABLES
-- =========================================================

-- 2.1 Countries (dimension)
CREATE TABLE countries (
    country_id   INT PRIMARY KEY,
    country_name VARCHAR(100),
    country_code VARCHAR(10)
);

INSERT INTO countries (country_id, country_name, country_code)
SELECT DISTINCT
    CAST(CountryID AS INT),
    CountryName,
    CountryCode
FROM staging_countries;

-- 2.2 Cities (dimension)
CREATE TABLE cities (
    city_id    INT PRIMARY KEY,
    city_name  VARCHAR(100),
    zipcode    VARCHAR(20),
    country_id INT REFERENCES countries(country_id)
);

INSERT INTO cities (city_id, city_name, zipcode, country_id)
SELECT DISTINCT
    CAST(CityID AS INT),
    CityName,
    Zipcode,
    CAST(CountryID AS INT)
FROM staging_cities;

-- 2.3 Categories (dimension)
CREATE TABLE categories (
    category_id   INT PRIMARY KEY,
    category_name VARCHAR(100)
);

INSERT INTO categories (category_id, category_name)
SELECT DISTINCT
    CAST(CategoryID AS INT),
    CategoryName
FROM staging_categories;

-- 2.4 Products (dimension)
CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(200),
    price         NUMERIC(12,4),
    category_id   INT REFERENCES categories(category_id),
    class         VARCHAR(50),
    modify_date   DATE,
    resistant     VARCHAR(20),
    is_allergic   VARCHAR(20),
    vitality_days INT
);

INSERT INTO products (
    product_id,
    product_name,
    price,
    category_id,
    class,
    modify_date,
    resistant,
    is_allergic,
    vitality_days
)
SELECT DISTINCT
    CAST(REGEXP_REPLACE(ProductID, '\.0$', '') AS INT),
    ProductName,
    CAST(Price AS NUMERIC(12,4)),
    CAST(REGEXP_REPLACE(CategoryID, '\.0$', '') AS INT),
    Class,
    NULLIF(ModifyDate,'')::DATE,
    Resistant,
    IsAllergic,
    CAST(REGEXP_REPLACE(VitalityDays, '\.0$', '') AS INT)
FROM staging_products;

-- 2.5 Employees (dimension)
CREATE TABLE employees (
    employee_id    INT PRIMARY KEY,
    first_name     VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name      VARCHAR(100),
    birth_date     DATE,
    gender         VARCHAR(20),
    city_id        INT REFERENCES cities(city_id),
    hire_date      DATE
);

INSERT INTO employees (
    employee_id,
    first_name,
    middle_initial,
    last_name,
    birth_date,
    gender,
    city_id,
    hire_date
)
SELECT DISTINCT
    CAST(EmployeeID AS INT),
    FirstName,
    MiddleInitial,
    LastName,
    NULLIF(BirthDate,'')::DATE,
    Gender,
    CAST(CityID AS INT),
    NULLIF(HireDate,'')::DATE
FROM staging_employees;

-- 2.6 Customers (dimension)
CREATE TABLE customers (
    customer_id    INT PRIMARY KEY,
    first_name     VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name      VARCHAR(100),
    city_id        INT REFERENCES cities(city_id),
    address        VARCHAR(255)
);

INSERT INTO customers (
    customer_id,
    first_name,
    middle_initial,
    last_name,
    city_id,
    address
)
SELECT DISTINCT
    CAST(CustomerID AS INT),
    FirstName,
    MiddleInitial,
    LastName,
    CAST(CityID AS INT),
    Address
FROM staging_customers;

-- 2.7 Sales (fact)
CREATE TABLE sales (
    sales_id           INT PRIMARY KEY,
    salesperson_id     INT REFERENCES employees(employee_id),
    customer_id        INT REFERENCES customers(customer_id),
    product_id         INT REFERENCES products(product_id),
    quantity           INT,
    discount_pct       NUMERIC(5,2),   
    total_price        NUMERIC(14,4),
    sales_date         DATE,
    transaction_number VARCHAR(50)
);

INSERT INTO sales (
    sales_id,
    salesperson_id,
    customer_id,
    product_id,
    quantity,
    discount_pct,
    total_price,
    sales_date,
    transaction_number
)
SELECT
    CAST(SalesID AS INT),
    CAST(SalesPersonID AS INT),
    CAST(CustomerID AS INT),
    CAST(ProductID AS INT),
    CAST(Quantity AS INT),
    CAST(COALESCE(NULLIF(Discount,''),'0') AS NUMERIC(5,2)),
    CAST(COALESCE(NULLIF(TotalPrice,''),'0') AS NUMERIC(14,4)),
    NULLIF(SalesDate,'')::DATE,
    TransactionNumber
FROM staging_sales;

-- =========================================================
-- SECTION 3: DATA QUALITY CHECKS / BASIC EDA
-- =========================================================

-- 3.1 Sales record completeness
SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(sales_date) AS non_null_sales_date,
    COUNT(total_price) AS non_null_total_price
FROM sales;

-- 3.2 Orphaned FKs (sales missing matching dimension records)
SELECT s.sales_id
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.customer_id
LEFT JOIN employees e ON s.salesperson_id = e.employee_id
LEFT JOIN products  p ON s.product_id = p.product_id
WHERE c.customer_id IS NULL
   OR e.employee_id IS NULL
   OR p.product_id IS NULL
LIMIT 20;

-- 3.3 Recalculate total_price from product price × quantity × discount
-- Assumes discount_pct stored as fraction (0.10 = 10%).
-- If CSV uses 10 for 10%, change (1 - discount_pct) to (1 - discount_pct / 100.0).
UPDATE sales s
SET total_price =
    ROUND(
        p.price * s.quantity * (1 - COALESCE(s.discount_pct, 0)),
        2
    )
FROM products p
WHERE s.product_id = p.product_id;

-- 3.4 Summary stats for sales amount
SELECT
    ROUND(MIN(total_price), 2) AS min_sale_amount,
    ROUND(MAX(total_price), 2) AS max_sale_amount,
    ROUND(AVG(total_price), 2) AS avg_sale_amount,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_price) AS median_sale_amount
FROM sales;

-- 3.5 Top 5 cities by sales
SELECT
    ci.city_name,
    ROUND(SUM(s.total_price), 2) AS revenue
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN cities    ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY revenue DESC
LIMIT 5;

-- =========================================================
-- SECTION 4: BUSINESS OBJECTIVE 1 – SALES & REVENUE TRENDS
-- =========================================================

-- 4.1 Daily sales: orders, units, revenue
SELECT
    sales_date AS sales_day,
    COUNT(DISTINCT transaction_number) AS num_transactions,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM sales
GROUP BY sales_date
ORDER BY sales_day;

-- 4.2 Sales by city: transactions, units, revenue
SELECT
    ci.city_name,
    COUNT(DISTINCT s.transaction_number) AS num_transactions,
    SUM(s.quantity) AS total_units_sold,
    ROUND(SUM(s.total_price), 2) AS total_revenue
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN cities    ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- 4.3 Revenue by country.
-- Note: dataset currently only includes United States,
-- but this query generalizes if more countries are added.
SELECT
    co.country_name,
    ROUND(SUM(s.total_price), 2) AS total_revenue,
    COUNT(*) AS num_sales
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN cities    ci ON cu.city_id = ci.city_id
JOIN countries co ON ci.country_id = co.country_id
GROUP BY co.country_name
ORDER BY total_revenue DESC;

-- =========================================================
-- SECTION 5: BUSINESS OBJECTIVE 2 – EMPLOYEE PERFORMANCE
-- =========================================================

-- 5.1 Top 10 salespeople by revenue
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    ROUND(SUM(s.total_price), 2) AS total_revenue,
    COUNT(DISTINCT s.transaction_number) AS transactions_handled,
    SUM(s.quantity) AS units_sold
FROM sales s
JOIN employees e ON s.salesperson_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 5.2 Average discount given by salesperson
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    ROUND(AVG(s.discount_pct), 4) AS avg_discount_pct,
    COUNT(*) AS num_sales
FROM sales s
JOIN employees e ON s.salesperson_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY avg_discount_pct DESC;

-- 5.3 Product mix by employee (category revenue & share)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    c.category_name,
    ROUND(SUM(s.total_price), 2) AS category_revenue,
    ROUND(
        100.0 * SUM(s.total_price)
        / NULLIF(SUM(SUM(s.total_price)) OVER (PARTITION BY e.employee_id), 0),
        2
    ) AS category_revenue_share_pct
FROM sales s
JOIN employees  e ON s.salesperson_id = e.employee_id
JOIN products   p ON s.product_id     = p.product_id
JOIN categories c ON p.category_id    = c.category_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    c.category_name
ORDER BY
    e.employee_id,
    category_revenue DESC;

-- =========================================================
-- SECTION 6: BUSINESS OBJECTIVE 3 – CUSTOMERS & PRODUCTS
-- =========================================================

-- 6.1 Top 20 customers by lifetime value
SELECT
    cu.customer_id,
    cu.first_name,
    cu.last_name,
    ROUND(SUM(s.total_price), 2) AS total_spent,
    COUNT(DISTINCT s.transaction_number) AS num_transactions,
    ROUND(AVG(s.total_price), 2) AS avg_transaction_value
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name
ORDER BY total_spent DESC
LIMIT 20;

-- 6.2 Revenue by product category
SELECT
    cat.category_name,
    ROUND(SUM(s.total_price), 2) AS total_revenue,
    SUM(s.quantity) AS units_sold
FROM sales s
JOIN products   pr  ON s.product_id = pr.product_id
JOIN categories cat ON pr.category_id = cat.category_id
GROUP BY cat.category_name
ORDER BY total_revenue DESC;

-- 6.3 Top 20 products by revenue
SELECT
    pr.product_id,
    pr.product_name,
    SUM(s.quantity) AS units_sold,
    ROUND(SUM(s.total_price), 2) AS total_revenue,
    ROUND(AVG(pr.price), 2) AS avg_unit_price
FROM sales s
JOIN products pr ON s.product_id = pr.product_id
GROUP BY pr.product_id, pr.product_name
ORDER BY total_revenue DESC
LIMIT 20;

-- 6.4 Basket size: items and units per transaction (top 30 by value)
SELECT
    transaction_number,
    COUNT(*) AS line_items,
    SUM(quantity) AS total_units,
    ROUND(SUM(total_price), 2) AS transaction_value
FROM sales
GROUP BY transaction_number
ORDER BY transaction_value DESC
LIMIT 30;

-- 6.5 High-value products (average revenue per sale)
SELECT
    product_id,
    COUNT(*) AS times_purchased,
    ROUND(AVG(quantity), 2) AS avg_qty,
    ROUND(AVG(total_price), 2) AS avg_revenue
FROM sales
GROUP BY product_id
ORDER BY avg_revenue DESC
LIMIT 10;

-- 6.6 Category share of wallet for top customers
WITH customer_spend AS (
    SELECT
        cu.customer_id,
        cu.first_name,
        cu.last_name,
        cat.category_name,
        ROUND(SUM(s.total_price), 2) AS category_spend
    FROM sales s
    JOIN customers cu ON s.customer_id = cu.customer_id
    JOIN products  pr ON s.product_id = pr.product_id
    JOIN categories cat ON pr.category_id = cat.category_id
    GROUP BY cu.customer_id, cu.first_name, cu.last_name, cat.category_name
),
customer_totals AS (
    SELECT
        customer_id,
        SUM(category_spend) AS total_spend
    FROM customer_spend
    GROUP BY customer_id
)
SELECT
    cs.customer_id,
    cs.first_name,
    cs.last_name,
    cs.category_name,
    cs.category_spend,
    ROUND(cs.category_spend / ct.total_spend * 100, 2) AS pct_of_wallet
FROM customer_spend cs
JOIN customer_totals ct ON cs.customer_id = ct.customer_id
ORDER BY cs.customer_id, pct_of_wallet DESC;

-- =========================================================
-- SECTION 7: ANALYTICS VIEW FOR TABLEAU
-- ---------------------------------------------------------
-- A single flattened view that Tableau can connect to directly.
-- =========================================================

CREATE OR REPLACE VIEW sales_analytics AS
SELECT
    s.sales_id,
    s.sales_date,
    s.quantity,
    s.discount_pct,
    s.total_price,
    s.transaction_number,
    e.employee_id,
    e.first_name  AS employee_first_name,
    e.last_name   AS employee_last_name,
    cu.customer_id,
    cu.first_name AS customer_first_name,
    cu.last_name  AS customer_last_name,
    ci.city_name,
    co.country_name,
    p.product_id,
    p.product_name,
    p.price       AS list_price,
    c.category_name
FROM sales s
JOIN customers cu ON s.customer_id   = cu.customer_id
JOIN cities    ci ON cu.city_id      = ci.city_id
JOIN countries co ON ci.country_id   = co.country_id
JOIN employees e ON s.salesperson_id = e.employee_id
JOIN products  p ON s.product_id     = p.product_id
JOIN categories c ON p.category_id   = c.category_id;
