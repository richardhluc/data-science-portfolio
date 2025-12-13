# Nutritional Risk Assessment in the Fast-Food Industry

## Overview
End-to-end analysis of a fast-food nutrition dataset (515 menu items across 8 chains) to compare nutrient profiles, identify high-risk items, and build interpretable models explaining calories and total fat. Includes an interpretable classification exercise (McDonald’s vs. Subway) and a Random Forest benchmark.

## Business Questions
- How do nutritional profiles differ across major fast-food chains?
- Which restaurants and items pose the highest nutritional risk (fat, sugar, calories)?
- Which nutrients most strongly drive calories and total fat?
- Can McDonald’s vs. Subway items be classified using nutrients alone?

## Data
- **Source:** Kaggle fast food nutrition dataset (`fast_food_data.csv`)
- **Rows:** 515 menu items across 8 chains
- **Key fields:** calories, total_fat, sat_fat, sugar, sodium, protein, cholesterol, total_carb, calcium
- **Missingness:**  
  Fiber (~2.3%) and protein (~0.2%) minor; calcium/vitamins (~41%) excluded from complete-case models

## Methods
- **EDA / risk scoring:** item-level risk via `total_fat × sugar`; restaurant-level comparisons; correlation analysis (subset)
- **Models:**
  - Logistic regression: McDonald’s (1) vs. Subway (0)
  - Linear regression (Calories): `calories ~ sat_fat + fiber + sugar`
  - Linear regression (Total Fat): `total_fat ~ cholesterol + total_carb + restaurant` (balanced subset)
  - Random Forest classifier (benchmark)

## Key Results
- **Top risk items:** McDonald’s Sweet N’ Spicy Honey BBQ Tenders and Dairy Queen Cheese Curds rank highest on fat × sugar
- **Restaurant risk:** Burger King, Sonic, and Dairy Queen show highest average saturated fat
- **Calories model:** R² ≈ 0.67; saturated fat is the dominant standardized driver
- **Classification:** Logistic regression accuracy ≈ 59.5%; Random Forest shows strong apparent fit but indicates overfitting without a held-out test split

## Artifacts
- **Figures:** `/figures/`
- **Tables:** `/outputs/`
- **Models:**
  - `/models/fastfood_calories_best_lm.rds`
  - `/models/fastfood_mcd_vs_subway_rf.rds`

## Tech Stack
R · tidyverse · ggplot2 · broom · lm.beta · ggcorrplot · randomForest

