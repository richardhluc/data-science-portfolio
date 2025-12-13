/*
============================================================
US Home Value Trend Analysis

Business Proposition: Housing market analysts, lenders, and 
investors seek to understand how home values evolve across 
regions over time. This SQL project analyzes Zillow Home 
Value Index (ZHVI) data to uncover growth leaders and lagging 
markets, assess volatility, and evaluate long-term recovery 
patterns that inform valuation, risk assessment, and 
investment decisions.
============================================================
*/

-- =========================================================
-- SECTION 0: CLEANUP (DROP TABLES IF THEY EXIST)
-- =========================================================

DROP TABLE IF EXISTS zhvi_analytics;
DROP TABLE IF EXISTS zhvi_staging;

-- =========================================================
-- SECTION 1: STAGING TABLE (RAW CSV IMPORT)
-- =========================================================

CREATE TABLE zhvi_staging (
    region_id   INT,
    size_rank   INT,
    region_name VARCHAR(255),
    region_type VARCHAR(50),
    state_name  VARCHAR(50),
    date        DATE,
    zhvi        NUMERIC(12,2) 
);

/*
============================================================
UPSTREAM DATA PREPROCESSING (PYTHON)
------------------------------------------------------------
The original Zillow ZHVI dataset was provided in wide format
(one column per month). Prior to SQL ingestion, Python was
used to reshape the data into a normalized long format
suitable for time-series analysis.

Preprocessing steps performed in Python:
- Loaded raw Zillow ZHVI CSV
- Reshaped data from wide to long using pandas.melt()
- Converted date columns to proper DATE format
- Exported cleaned long-format CSV for SQL ingestion

This preprocessing ensures:
- One record per (region_id, date)
- Efficient SQL analytics and window functions
- Clean integration with Tableau time-series dashboards

Python code (reference):

import pandas as pd

df = pd.read_csv("zillow_zhvi.csv")

df_long = df.melt(
    id_vars=["RegionID", "SizeRank", "RegionName", "RegionType", "StateName"],
    var_name="Date",
    value_name="ZHVI"
)

df_long["Date"] = pd.to_datetime(df_long["Date"]).dt.date

df_long.to_csv("zillow_zhvi_clean.csv", index=False)
============================================================
*/

-- =========================================================
-- SECTION 2: ANALYTICS/NORMALIZED TABLE (TIME-SERIES MODEL)
-- =========================================================

CREATE TABLE zhvi_analytics (
    region_id   INT,
    region_name VARCHAR(255),
    region_type VARCHAR(50),
    state_name  VARCHAR(50),
    date        DATE,
    zhvi        NUMERIC(12,2),
    PRIMARY KEY (region_id, date)
);

INSERT INTO zhvi_analytics (region_id, region_name, region_type, state_name, date, zhvi)
SELECT
    region_id,
    region_name,
    region_type,
    state_name,
    date,
    zhvi
FROM zhvi_staging;

-- =========================================================
-- SECTION 3: DATA QUALITY CHECKS / BASIC EDA
-- =========================================================

-- 3.1 Missing values per region
SELECT
    region_name,
    COUNT(*)               AS total_records,
    COUNT(zhvi)            AS non_null_records,
    COUNT(*) - COUNT(zhvi) AS null_records
FROM zhvi_analytics
GROUP BY region_name
ORDER BY null_records DESC;

-- 3.2 Summary statistics for ZHVI (USD)
SELECT 
    MIN(zhvi) AS min_zhvi_usd,
    MAX(zhvi) AS max_zhvi_usd,
    ROUND(AVG(zhvi), 2) AS avg_zhvi_usd,
    ROUND(
        PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY zhvi)::NUMERIC,
        2
    ) AS median_zhvi_usd
FROM zhvi_analytics;

-- =========================================================
-- SECTION 4: BUSINESS OBJECTIVE 1 – GROWTH LEADERS & LAGGARDS
-- ---------------------------------------------------------
-- Identify regions with highest and lowest long-term home
-- value growth (total $ and % growth).
-- =========================================================

WITH region_growth AS (
    SELECT
        region_id,
        region_name,
        state_name,
        MAX(zhvi) AS max_zhvi,
        MIN(zhvi) AS min_zhvi
    FROM zhvi_analytics
    GROUP BY region_id, region_name, state_name
),
growth_metrics AS (
    SELECT
        region_id,
        region_name,
        state_name,
        max_zhvi - min_zhvi AS total_growth_usd,
        CASE
            WHEN min_zhvi > 0
            THEN ROUND(((max_zhvi - min_zhvi) / min_zhvi) * 100, 2)
            ELSE NULL
        END AS pct_growth
    FROM region_growth
),
top5 AS (
    SELECT
        'Top 5' AS growth_type,
        region_name,
        state_name,
        total_growth_usd,
        pct_growth,
        ROW_NUMBER() OVER (ORDER BY pct_growth DESC NULLS LAST) AS sort_order
    FROM growth_metrics
    ORDER BY pct_growth DESC NULLS LAST
    LIMIT 5
),
bottom5 AS (
    SELECT
        'Bottom 5' AS growth_type,
        region_name,
        state_name,
        total_growth_usd,
        pct_growth,
        ROW_NUMBER() OVER (ORDER BY pct_growth ASC NULLS LAST) + 5 AS sort_order
    FROM growth_metrics
    ORDER BY pct_growth ASC NULLS LAST
    LIMIT 5
)
SELECT
    growth_type,
    region_name,
    state_name,
    total_growth_usd,
    pct_growth
FROM (
    SELECT * FROM top5
    UNION ALL
    SELECT * FROM bottom5
) t
ORDER BY sort_order;

-- =========================================================
-- SECTION 5: BUSINESS OBJECTIVE 2 – MONTHLY VOLATILITY & 
--                                      ROLLING TRENDS
-- ---------------------------------------------------------
-- Identify extreme monthly changes and smooth trends using
-- rolling 12-month averages.
-- =========================================================

-- 5.1 Top 10 biggest monthly gains
WITH monthly_changes AS (
    SELECT
        region_id,
        region_name,
        date,
        zhvi,
        zhvi - LAG(zhvi) OVER (PARTITION BY region_id ORDER BY date) AS monthly_change_usd
    FROM zhvi_analytics
)
SELECT
    region_name,
    date,
    zhvi,
    monthly_change_usd
FROM monthly_changes
WHERE monthly_change_usd IS NOT NULL
ORDER BY monthly_change_usd DESC
LIMIT 10;

-- 5.2 Top 10 biggest monthly drops
WITH monthly_changes AS (
    SELECT
        region_id,
        region_name,
        date,
        zhvi,
        zhvi - LAG(zhvi) OVER (PARTITION BY region_id ORDER BY date) AS monthly_change_usd
    FROM zhvi_analytics
)
SELECT
    region_name,
    date,
    zhvi,
    monthly_change_usd
FROM monthly_changes
WHERE monthly_change_usd IS NOT NULL
ORDER BY monthly_change_usd ASC
LIMIT 10;

-- 5.3 Rolling 12-month average (Decembers only – annual view)
SELECT
    region_id,
    region_name,
    date,
    ROUND(AVG(zhvi) OVER (
        PARTITION BY region_id
        ORDER BY date
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_12mo_avg
FROM zhvi_analytics
WHERE EXTRACT(MONTH FROM date) = 12
ORDER BY region_id, date;

-- =========================================================
-- SECTION 6: BUSINESS OBJECTIVE 3 – ANNUAL GROWTH EXTREMES
-- ---------------------------------------------------------
-- Year-over-year average ZHVI, plus each region’s best and
-- worst percentage change year.
-- =========================================================

WITH region_yearly AS (
    SELECT
        region_name,
        EXTRACT(YEAR FROM date) AS year,
        ROUND(AVG(zhvi), 2) AS avg_zhvi_usd
    FROM zhvi_analytics
    GROUP BY region_name, EXTRACT(YEAR FROM date)
),
region_yearly_changes AS (
    SELECT
        region_name,
        year,
        avg_zhvi_usd,
        ROUND(
			avg_zhvi_usd
            	- LAG(avg_zhvi_usd) OVER (PARTITION BY region_name ORDER BY year),
			2
		) AS annual_change_usd,
        CASE
            WHEN LAG(avg_zhvi_usd) OVER (PARTITION BY region_name ORDER BY year) > 0
            THEN ROUND(
                (avg_zhvi_usd
                    - LAG(avg_zhvi_usd) OVER (PARTITION BY region_name ORDER BY year))
                / LAG(avg_zhvi_usd) OVER (PARTITION BY region_name ORDER BY year)
                * 100,
                2
            )
            ELSE NULL
        END AS pct_change
    FROM region_yearly
),
max_min_pct AS (
    SELECT
        region_name,
        MAX(pct_change) AS max_pct_change,
        MIN(pct_change) AS min_pct_change
    FROM region_yearly_changes
    GROUP BY region_name
)
SELECT
    r.region_name,
    r.year,
    r.avg_zhvi_usd,
    r.annual_change_usd,
    r.pct_change,
    CASE
        WHEN r.pct_change = m.max_pct_change THEN 'Highest'
        WHEN r.pct_change = m.min_pct_change THEN 'Lowest'
    END AS change_type
FROM region_yearly_changes r
JOIN max_min_pct m
  ON r.region_name = m.region_name
WHERE r.pct_change = m.max_pct_change
   OR r.pct_change = m.min_pct_change
ORDER BY r.region_name, change_type DESC;

-- =========================================================
-- SECTION 7: BUSINESS OBJECTIVE 4 – POSITIVE GROWTH STREAKS
-- ---------------------------------------------------------
-- Longest consecutive runs of positive monthly growth
-- (market momentum / resilience).
-- =========================================================

WITH monthly_change AS (
    SELECT
        region_name,
        date,
        zhvi,
        CASE
            WHEN zhvi - LAG(zhvi) OVER (PARTITION BY region_name ORDER BY date) > 0
            THEN 1 ELSE 0
        END AS positive_month
    FROM zhvi_analytics
),
streaks AS (
    SELECT
        region_name,
        date,
        SUM(
            CASE
                WHEN positive_month = 0 THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY region_name
            ORDER BY date
            ROWS UNBOUNDED PRECEDING
        ) AS streak_group
    FROM monthly_change
),
streak_lengths AS (
    SELECT
        region_name,
        streak_group,
        COUNT(*) AS streak_length
    FROM streaks
    GROUP BY region_name, streak_group
)
SELECT
    region_name,
    MAX(streak_length) AS longest_positive_growth_months
FROM streak_lengths
GROUP BY region_name
ORDER BY longest_positive_growth_months DESC
LIMIT 10;

-- =========================================================
-- SECTION 8: BUSINESS OBJECTIVE 5 – POST-CRISIS RECOVERY
-- ---------------------------------------------------------
-- Recovery after the 2007–2008 housing downturn (2007–2015):
-- lowest point vs post-2012 peak and % recovery.
-- =========================================================

WITH rolling_yearly AS (
    SELECT
        region_name,
        EXTRACT(YEAR FROM date) AS year,
        AVG(zhvi) AS avg_zhvi_usd
    FROM zhvi_analytics
    GROUP BY region_name, EXTRACT(YEAR FROM date)
),
recovery AS (
    SELECT
        region_name,
        ROUND(MIN(avg_zhvi_usd), 2) AS lowest_point,
        ROUND(MAX(avg_zhvi_usd) FILTER (WHERE year >= 2012), 2) AS post_recovery_max,
        CASE
            WHEN MIN(avg_zhvi_usd) > 0
                 AND MAX(avg_zhvi_usd) FILTER (WHERE year >= 2012) IS NOT NULL
            THEN ROUND(
                (MAX(avg_zhvi_usd) FILTER (WHERE year >= 2012) - MIN(avg_zhvi_usd))
                / MIN(avg_zhvi_usd) * 100,
                2
            )
            ELSE NULL
        END AS pct_recovery
    FROM rolling_yearly
    WHERE year BETWEEN 2007 AND 2015
    GROUP BY region_name
)
SELECT
    region_name,
    lowest_point,
    post_recovery_max,
    pct_recovery
FROM recovery
ORDER BY pct_recovery DESC NULLS LAST
LIMIT 10;