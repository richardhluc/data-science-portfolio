# Student Academic Success Prediction

## Overview
End-to-end modeling of secondary school data to predict final student performance (G3) and identify at-risk students. The project combines exploratory analysis, statistical screening, and regression modeling to support early academic intervention.

## Business Questions
- Which factors most strongly predict final student grades?
- How much predictive power comes from prior term grades (G1, G2)?
- Can a regression model be used to flag students at academic risk?

## Data
- **Source:** UCI Machine Learning Repository (Student Performance dataset): student_academic_success_data.csv
- **Rows:** 395 students
- **Key fields:** G1, G2, G3, absences, age, parental education, family & school factors
- **Missingness:** Minor (handled via imputation)

## Methods
- **EDA:** grade distributions, correlations, ANOVA screening
- **Feature engineering:** total absences across terms
- **Models:**
  - Linear Regression
  - Lasso Regression
  - Support Vector Regression (SVR, tuned)
- **Metrics:** RMSE, MAE, R² (cross-validation + test set)

## Key Results
- **Prior grades dominate:** G2 (corr ≈ 0.90) and G1 (corr ≈ 0.80) are the strongest predictors of final performance
- **Early-warning tradeoff:** Removing G1/G2 increases RMSE from ~2.4 to ~4.2, quantifying the cost of early prediction
- **Best model:** Tuned SVR with prior grades achieves R² ≈ 0.73 and RMSE ≈ 2.4 on the test set
- **At-risk detection:** Regression outputs reliably flag failing students (high recall for G3 < 10)

## Artifacts
- **Figures:** `/figures/`
- **Tables:** `/outputs/`
- **Models:** `/models/school_best_svm_with_grades.pkl`

## Tech Stack
Python · pandas · NumPy · scikit-learn · scipy · matplotlib · seaborn · joblib

