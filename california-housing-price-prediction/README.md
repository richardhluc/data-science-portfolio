# California Housing Price Insights

## Overview
End-to-end analysis of California census housing data to support property valuation, investment analysis, and lending risk assessment. The project combines exploratory analysis, feature engineering, and tree-based machine learning to model median house values across diverse regional markets.

## Business Questions
- Which factors most strongly drive housing prices across California?
- How do income and geographic location affect home values?
- Do housing stock characteristics improve price prediction?
- Can a machine-learning model accurately predict median house values?

## Data
- **Source:** Kaggle California Housing dataset
- **Rows:** ~20,600 census tracts
- **Key fields:** latitude, longitude, median_income, housing_median_age, total_rooms, households, ocean_proximity
- **Missingness:** Minor missingness in `total_bedrooms` handled via imputation

## Methods
- **EDA:** distributions, correlations, geographic price patterns
- **Feature engineering:** rooms per household, population per household, bedroom ratio
- **Models:** Linear Regression, Decision Tree Regression, Random Forest Regression (tuned benchmark)
- **Metrics:** RMSE, R² (cross-validation + test set)

## Key Results
- **Income dominance:** Median income is the strongest predictor of house value (corr ≈ 0.69)
- **Geographic signal:** Latitude/longitude separate high-value coastal markets from inland regions
- **Nonlinearity:** Tree-based models outperform linear regression
- **ML benchmark:** Tuned Random Forest achieves R² ≈ 0.84 with RMSE ≈ $50K

## Artifacts
- **Figures:** `/figures/`
- **Tables:** `/outputs/`
- **Models:** `/models/california_housing_best_model.pkl`

## Tech Stack
Python · pandas · numpy · matplotlib · seaborn · scikit-learn · joblib
