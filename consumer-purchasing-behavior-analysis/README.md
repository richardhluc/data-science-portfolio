# Consumer Behavior Segmentation (Customer Personality Clustering)

## Overview
End-to-end customer segmentation using demographics, purchase behavior, and campaign engagement to identify actionable customer groups for targeting, retention, and offer personalization. The project combines feature engineering, PCA, and K-Means clustering.

## Business Questions
- Can customers be segmented based on spending and engagement behavior?
- Which segments drive revenue vs. indicate risk?
- How can clusters guide campaign and channel strategy?

## Data
- **Source:** Kaggle (Consumer Behavior dataset): consumer_behavior_data.csv
- **Rows:** 2,240 customers (2,213 after processing)
- **Key fields:** Income, Education, Marital_Status, Recency, product spend, purchase channels
- **Missingness:** None after validation

## Methods
- **EDA:** distributions and spend patterns
- **Preprocessing:** RobustScaler + OneHotEncoder
- **Dimensionality reduction:** PCA
- **Clustering:** K-Means (elbow + silhouette)
- **Final model:** k = 4

## Key Results
- **High-value segments:** Clusters 0 and 3 show highest income and total spend
- **At-risk segment:** Cluster 1 exhibits low spend and low engagement (reactivation opportunity)
- **Behavioral insight:** Cluster 2 reflects family-oriented and deal-driven purchasing behavior

## Artifacts
- **Figures:** `/figures/`
- **Tables:** `/outputs/`
- **Model:** `/models/customer_personality_clustering_pipeline.pkl`

## Tech Stack
Python · pandas · NumPy · scikit-learn · matplotlib · PCA · K-Means · joblib
