# Mushroom Edibility Classification (Neural Networks)

## Overview
End-to-end classification of mushroom edibility using categorical physical attributes. The project evaluates neural-network performance on fully encoded features and on a PCA-compressed representation to assess predictive accuracy, dimensionality reduction, and generalization.

## Business Question
- Can physical mushroom characteristics reliably predict whether a mushroom is edible or poisonous, and can dimensionality reduction preserve predictive performance?

## Data
- **Source:** UCI Mushroom Dataset (via Kaggle)
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
- **Perfect classification:** Accu

