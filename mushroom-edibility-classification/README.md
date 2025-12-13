# Mushroom Edibility Classification (Neural Networks)

## Overview
End-to-end classification of mushroom edibility using categorical physical attributes. The project evaluates neural-network performance on fully encoded features and on a PCA-compressed representation to assess predictive accuracy, dimensionality reduction, and generalization.

## Business Question
- Can physical mushroom characteristics reliably predict whether a mushroom is edible or poisonous, and can dimensionality reduction preserve predictive performance?

## Data
- **Source:** UCI Machine Learning Repository (Mushroom dataset)
- **Rows:** 8,124 observations
- **Features:** 22 categorical attributes
- **Target:** `class` (e = edible, p = poisonous)
- **Missingness:** None
- **Class balance:** Edible (4,208), Poisonous (3,916)

## Methods
- **Preprocessing:** One-hot encoding, label encoding, stratified train/test split
- **Models:**
  - Neural Network (fully encoded, 116 dimensions)
  - PCA + Neural Network (40 components, ~95% variance retained)
- **Evaluation:** Confusion matrix, Precision, Recall, F1, ROC–AUC, PR curves

## Key Results
- **Perfect classification:** Accuracy, Precision, Recall, F1, and ROC–AUC = 1.00 on the test set
- **Dimensionality reduction:** PCA reduces features by ~65% (116 → 40) with no loss in performance
- **Deployment preference:** PCA-based model favored for efficiency and generalization

## Artifacts
- **Figures:** `/figures/`
- **Tables:** `/outputs/metrics_summary_mushroom_nn.csv`
- **Models:** `/models/mushroom_pca_model.h5`

## Tech Stack
Python · pandas · NumPy · scikit-learn · TensorFlow / Keras · matplotlib · seaborn · PCA
