# Grocery Sales Performance Analysis

## Overview
End-to-end SQL analytics project analyzing grocery sales transactions to support revenue growth, product strategy, and sales performance optimization. The project transforms raw sales data into a normalized relational model, performs data quality validation, and delivers business-ready analytics consumed in Tableau dashboards to inform pricing, merchandising, and salesforce decisions.

## Business Questions
- How do grocery revenue and unit sales trend over time?
- Which cities generate the highest total revenue?
- Which product categories and individual products drive the most revenue?
- Which salespeople contribute the most to overall sales performance?
- How does product mix vary by salesperson, and where do cross-sell opportunities exist?

## Data
- **Source:** Kaggle (Grocery Sales dataset): categories.csv, cities.csv, countries.csv, customers.csv, employees.csv, products.csv, sales.csv
- **Core entities:** sales transactions, products, categories, customers, employees, cities, countries
- **Schema design:**
  - Normalized star-like schema
  - Fact table: `sales`
  - Dimension tables: products, categories, customers, employees, cities, countries
- **Data preparation:**
  - Raw CSVs ingested into staging tables
  - IDs standardized during normalization
  - Dates cleaned for time-series analysis
  - Numeric fields validated for revenue and quantity calculations
- **Data quality:** null and type validation, enforced foreign-key integrity, revenue range checks via summary statistics

## Methods
- **Data modeling & ETL (SQL):**
  - Staging tables mirror raw CSV structure
  - Dimension and fact tables created with primary and foreign keys
  - Clear separation between raw ingestion and analytics-ready schema
- **Analytics & business logic:**
  - Monthly revenue and unit sales trends
  - Revenue aggregation by city, category, product, and salesperson
  - Top-N analysis for products and employees
  - Category contribution analysis
  - Product mix analysis by employee using percentage-of-revenue logic
- **BI integration:** SQL queries structured for direct Tableau consumption and aligned to dashboard KPIs

## Key Results
- **Revenue trends:** Strong early-period performance with a decline in the final month, likely driven by partial-period data or seasonality
- **Geographic performance:** A small set of cities (e.g., Tucson, Jackson, Sacramento) dominate total revenue, indicating concentrated demand
- **Category performance:** Confections, meat, and poultry lead revenue, while produce and beverages provide diversification
- **Top products:** Individual products generate approximately $18–19M in revenue, identifying promotion-ready “hero” items
- **Salesperson performance:** Revenue contribution is uneven, with top employees exceeding $190M in total sales
- **Product mix by employee:** Distinct category mix patterns reveal opportunities for targeted training and cross-sell optimization

## Artifacts
- **SQL:** staging tables, normalized schema creation, data quality validation, and business analytics queries
- **Dashboards (Tableau):**
  - Monthly Revenue & Units Sold Trend
  - Revenue by City
  - Revenue by Category
  - Top Products by Revenue
  - Top Salespeople by Revenue
  - Product Mix by Employee

## Tech Stack
SQL (PostgreSQL-style) · Relational Data Modeling · Analytical SQL · Window Functions · Tableau

