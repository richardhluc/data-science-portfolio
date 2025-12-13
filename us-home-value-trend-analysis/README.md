# U.S. Home Value Trend Analysis

## Overview
End-to-end SQL analytics project analyzing U.S. home value trends using Zillow’s Home Value Index (ZHVI). The project transforms raw housing data into a structured time-series model, performs data quality validation, and produces business-ready analytics consumed in Tableau dashboards to support market analysis, valuation, and investment decision-making.

## Business Questions
- How do home values vary across U.S. states and regions today?
- Which regions have experienced the highest and lowest long-term growth?
- Where is housing price volatility most pronounced over time?
- Which markets demonstrated the strongest recovery following the 2007–2008 housing crisis?
- What regions show sustained momentum through positive growth streaks?

## Data
- **Source:** Zillow (Home Value Index (ZHVI) dataset)
- **Core entities:**
  - Regions (state-level aggregation)
  - Monthly time-series home values (ZHVI)
- **Schema design:**
  - Staging table for raw CSV ingestion
  - Analytics table modeled as a time-series fact table with composite primary key (`region_id`, `date`)
- **Data preparation:**
  - Zillow data reshaped from wide to long format using Python (pandas)
  - Monthly ZHVI values standardized to a single date column
  - `SizeRank` retained in staging but excluded from analytics due to limited business relevance
- **Data quality:** missing value checks by region and validation of value ranges via summary statistics

## Methods
- **Data modeling & ETL (SQL):**
  - Staging table mirrors cleaned CSV structure
  - Analytics table created with appropriate data types and primary keys
  - Clear separation between raw ingestion and analytical modeling
- **Analytics & business logic:**
  - Long-term growth analysis using min/max ZHVI and percentage growth
  - Monthly volatility analysis with lag functions
  - Rolling 12-month averages to smooth price trends
  - Year-over-year growth calculations (best and worst annual performance)
  - Consecutive positive growth streak analysis for market momentum
  - Post-crisis recovery analysis comparing troughs to post-2012 peaks
- **BI integration:** SQL outputs structured for direct Tableau consumption and aligned to dashboard KPIs (ZHVI $, % growth, YoY change)

## Key Results
- **Current home values:** Coastal markets dominate current ZHVI levels, led by Hawaii and California
- **Growth leaders:** Hawaii, California, and the District of Columbia show the highest long-term percentage growth
- **Growth laggards:** Midwestern and southern states exhibit slower long-term appreciation
- **Market volatility:** Monthly changes highlight sharp appreciation and contraction around major economic events
- **Trend stability:** Rolling 12-month averages reveal sustained upward momentum while smoothing short-term noise
- **Post-crisis recovery:** Nevada, Idaho, and Arizona demonstrate the strongest rebounds following the housing downturn

## Artifacts
- **SQL:** staging and analytics table creation, data quality validation, and business analytics queries (growth, volatility, trends, recovery)
- **Dashboards (Tableau):**
  - Latest ZHVI Overview by State
  - U.S. Home Value Choropleth Map
  - Top & Bottom Growth Regions
  - Rolling 12-Month Home Value Trends
  - Year-Over-Year % Change Heatmap
  - Post-Crisis Recovery Analysis

## Tech Stack
SQL (PostgreSQL) · Time-Series Analysis · Analytical SQL · Window Functions · Tableau · Python (pandas for preprocessing)

