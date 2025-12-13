BOSTON HOUSING PRICE INSIGHTS

OVERVIEW: End-to-end analysis of Boston neighborhood housing data to support property valuation, lending risk assessment, and urban
planning. The project combines exploratory analysis, regularized regression, and nonlinear modeling to explain and predict median home
prices.

BUSINESS QUESTIONS
Which neighborhood factors most strongly drive home prices?
How do socioeconomic status and environmental factors affect valuations?
Do nonlinear relationships improve prediction accuracy?

DATA
Source: Kaggle Boston Housing dataset
Rows: 506 neighborhoods
Key fields: RM, LSTAT, NOX, TAX, INDUS, DIS, PTRATIO, CHAS, MEDV
Missingness: None (all fields complete)

METHODS
EDA: distributions, correlations, feature relationships
Preprocessing: scaling and imputation
Models: Ridge regression, Lasso regression, Polynomial Features + Ridge regression (benchmark)
Metrics: RMSE, R² (cross-validation + test set)

KEY RESULTS
Room effect: Average rooms per dwelling (RM) is the strongest positive price driver.
Socioeconomic impact: Higher lower-status population (LSTAT) strongly depresses prices.
Environmental costs: Pollution (NOX), taxes (TAX), and industrial zoning (INDUS) reduce valuations.
Nonlinearity: Polynomial Ridge captures nonlinear effects and outperforms linear baselines.
ML benchmark: Best model achieves R² ≈ 0.82 with RMSE ≈ $3.6K on the test set.

ARTIFACTS
Figures: /figures/
Tables: /outputs/
Models: /models/boston_best_model_refined.pkl

TECH STACK
Python · pandas · numpy · matplotlib · seaborn · scikit-learn · joblib
