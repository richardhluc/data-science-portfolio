# Restaurant Visitor Demand Forecasting

## Overview
End-to-end demand forecasting pipeline using historical restaurant visits, store metadata, and calendar signals to predict daily customer traffic and support staffing and inventory planning.

## Business Questions
- How do visits vary by time, holidays, and genre?
- Can daily visitors be predicted reliably?
- Which model performs best under time-based validation?

## Data
- **Sources:** Kaggle (Restaurant Visitor dataset): air_visit_data.csv, air_store_info.csv, date_info.csv
- **Merged dataset:** 252,108 rows
- **Target:** `visitors`
- **Cleaning:** encoding fixes
- **Final dataset:** 246,305 rows × 17 features

## Methods
- **EDA:** visitor trends and distributions
- **Feature engineering:** lags, rolling averages, calendar features
- **Split:** time-based train/validation
- **Models:** Linear Regression, Ridge Regression, Random Forest
- **Metrics:** RMSE, R²

## Key Results
- **Best model:** Random Forest achieves RMSE = 12.647 and R² = 0.501
- **Temporal patterns:** Weekends and holidays exhibit higher visitor volume

## Artifacts
- **Figures:** `/figures/`
- **Tables:** `/outputs/model_performance_summary.csv`
- **Model:** `/models/restaurant_visitors_best_model.pkl`

## Tech Stack
Python · pandas · NumPy · matplotlib · scikit-learn · joblib
