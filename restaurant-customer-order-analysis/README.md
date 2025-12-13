# Restaurant Customer Order Analysis

## Overview
End-to-end SQL analytics project analyzing restaurant orders, members, and menu data to support revenue growth, customer retention, and menu optimization. The project builds a normalized relational schema, performs data quality validation, and produces business-ready analytics consumed in Tableau dashboards.

## Business Questions
- How does revenue trend over time, and when are peak ordering periods?
- Which cities, restaurants, and menu items generate the most revenue?
- Which menu categories and products drive overall performance?
- How do customer engagement, frequency, and recency signal retention risk?
- Which meal combinations are most frequently purchased together?

## Data
- **Source:** Kaggle (Restaurant Members and Orders dataset): cities.csv, meal_types.csv, meals.csv, members.csv, monthly_member_totals.csv, order_details.csv, orders.csv, restaurant_types.csv, restaurants.csv, serve_types.csv
- **Core entities:** orders, order details, restaurants, members, meals, meal types, serve types, cities
- **Schema design:**
  - Normalized relational model with fact tables (`orders`, `order_details`)
  - Supporting dimension tables (members, restaurants, meals, cities, types)
  - Monthly member snapshot table for engagement, spend, and budget tracking
- **Data quality:** null checks, orphaned foreign-key validation, and revenue range validation

## Methods
- **Data modeling & ETL (SQL):**
  - Staging tables mirror raw CSV inputs
  - Normalized tables with enforced primary and foreign keys
- **Analytics & business logic:**
  - Revenue aggregation by restaurant, city, and restaurant type
  - Monthly revenue, order volume, and average order value trends
  - Peak ordering analysis by weekday and hour
  - RFM-style member analytics (recency, frequency, monetary value)
  - Menu performance and basket analysis
- **BI integration:** query outputs structured for direct Tableau consumption and aligned to dashboard KPIs

## Key Results
- **Revenue trends:** Strong early-period performance with a decline in the final month, suggesting partial-period data or seasonal effects
- **Restaurant performance:** Top locations generate approximately $120K–$135K in total revenue, indicating concentration
- **Temporal patterns:** Peak ordering aligns with lunch and dinner windows, supporting staffing optimization
- **Menu performance:** Top meals generate approximately $15K–$20K each, identifying promotion-ready “hero” items
- **Customer behavior:** RFM analysis distinguishes loyal, high-value members from customers with rising recency risk
- **Basket insights:** Frequently purchased meal pairs reveal bundling and cross-promotion opportunities

## Artifacts
- **SQL:** schema creation, data quality validation, and business analytics queries
- **Dashboards (Tableau):**
  - Revenue by Restaurant
  - Monthly Revenue & Average Order Value Trends
  - Peak Ordering Times (Weekday × Hour Heatmaps)
  - Top Meals by Revenue
  - Member Segmentation (Frequency vs. Monetary)
  - Frequently Bought-Together Meal Pairs

## Tech Stack
SQL (PostgreSQL) · Relational Data Modeling · Analytical SQL · Window Functions · Tableau
