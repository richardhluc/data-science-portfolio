# Socioeconomic Health Insurance Analysis

## Overview
End-to-end analysis of BRFSS 2021 survey data to examine how income, education, and home arrangement relate to primary health insurance type. The project combines exploratory segmentation, association testing, interpretable multi-class modeling, and a machine-learning benchmark.

## Business Questions
- How is primary insurance coverage distributed in the population?
- How do income, education, and housing arrangement differ across insurance types?
- Are insurance types statistically associated with socioeconomic factors?
- Can insurance type be predicted from income, education, and home status?

## Data
- **Source:** CDC (BRFSS 2021 dataset): health_data.csv
- **Rows loaded:** 438,693
- **Analytic sample:** 334,588 (after valid-code filtering)
- **Key fields:** PRIMINSR, INCOME3, EDUCA, RENTHOM1
- **Missingness:** Nonresponse and out-of-range codes removed (e.g., DK / refused)

## Methods
- **Recoding & cleaning:** labeled factor categories for PRIMINSR, INCOME3, EDUCA, RENTHOM1
- **EDA:** distributions and insurance mix by income, education, and home arrangement
- **Visualization:** segmented bar charts; EDUCA × PRIMINSR tile plot (faceted by home arrangement)
- **Statistics:** chi-square tests (insurance vs. income, education, home)
- **Models:**
  - Multinomial logistic regression (interpretable)
  - Random Forest classification (benchmark)
- **Metrics:** accuracy, confusion matrices, RF variable importance

## Key Results
- **Coverage mix (analytic sample):** Employer-based 41.4%, Medicare 29.4%, Uninsured 5.3%
- **Associations:** Insurance type strongly related to income, education, and home arrangement  
  (chi-square p < 2.2e-16; some sparse-cell warnings)
- **Multinomial model:** Best specification uses income, education, and home arrangement  
  (accuracy ≈ 0.517, in-sample)
- **ML benchmark:** Random Forest test accuracy ≈ 0.519
- **Feature importance (RF):** Income strongest predictor, followed by home arrangement and education

## Artifacts
- **Figures:** `/figures/`
- **Tables / exports:** `/outputs/`
- **Models:**
  - `/models/socioeconomic_insurance_best_multinom.rds`
  - `/models/socioeconomic_insurance_rf.rds`

## Tech Stack
R · tidyverse · ggplot2 · nnet · broom · randomForest · psych · lsr · car

