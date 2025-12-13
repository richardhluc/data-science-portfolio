# Avocado Price Market Analysis

## Overview
End-to-end analysis of U.S. retail avocado data (2015–2023) to support pricing, demand planning, and supply-chain optimization. The project combines exploratory analysis, interpretable regression, and a machine-learning benchmark to understand large avocado (PLU 4225) demand.

## Business Questions
- Which regions drive the most avocado volume?
- Where is price volatility highest?
- How large is the organic vs. conventional price premium?
- Can season, region, and type predict large-fruit demand?

## Data
- **Source:** Kaggle (Avocado dataset): avocados_market_data.csv
- **Rows:** ~53k observations (Date × region × type)
- **Key fields:** AveragePrice, TotalVolume, plu4225, region, type, Date
- **Missingness:** Core price and volume fields complete; bag-size fields (~23%) excluded

## Methods
- **EDA:** price volatility, demand concentration, seasonality
- **Feature engineering:** Year, Month, Season, `type_bin`
- **Models:**
  - Logistic regression (organic vs. conventional)
  - Linear regression (PLU 4225 sales)
  - Random Forest regression (benchmark)
- **Metrics:** MAE, RMSE, MAPE

## Key Results
- **Demand concentration:** Los Angeles (160M) and New York (106M) dominate 2021 volume
- **Price volatility:** Several metro markets show high conventional price variability
- **Organic premium:** Price strongly predicts organic vs. conventional (odds ratio ≈ 4,000 per +$1)
- **PLU 4225 drivers (linear model):**
  - R² ≈ 0.65
  - Type (organic vs. conventional) and region dominate
- **ML benchmark:** Random Forest explains ~88% of variance and cuts error roughly in half vs. linear regression

## Artifacts
- **Figures:** `/figures/`
- **Tables:** `/outputs/`
- **Models:**
  - `/models/large_avocado_sales_best_lm.rds`
  - `/models/large_avocado_sales_rf.rds`

## Tech Stack
R · tidyverse · ggplot2 · broom · lm.beta · ggcorrplot · randomForest
