# Global Tech Layoffs Analysis

## Overview
This project analyzes global tech layoff data to identify patterns and relationships between
layoffs and company characteristics such as industry, company stage, funding level, geography,
and company size.

The analysis emphasizes responsible interpretation of data by explicitly recognizing that
**correlation does not imply causation**.

---

## Objective
The goal of this project is to:
- Identify which company characteristics are most strongly associated with higher layoff counts
- Understand how layoffs are distributed across industries, funding stages, and regions
- Highlight factors that appear to influence layoffs more frequently, without making causal claims

This analysis is exploratory and descriptive, not predictive.

---

## Data
- `layoffs_raw.csv`  
  Original dataset prior to any cleaning or transformation

- `layoffs_cleaned.csv`  
  Cleaned dataset after handling missing values, duplicates, and inconsistent formatting

---

## Tools Used
- SQL
- Tableau

---

## Analytical Approach

### 1. Data Cleaning (SQL)
Before analysis, the raw dataset required cleaning. Using SQL, I:
- Removed duplicate records
- Standardized categorical fields (industry, country, company stage)
- Handled missing and null values
- Ensured consistent data types for numerical analysis

This step was essential to ensure accurate aggregations and comparisons.

---

### 2. Exploratory Analysis (SQL)
SQL was used to:
- Aggregate total and average layoffs across industries
- Compare layoffs by company stage and funding level
- Analyze geographic distribution of layoffs
- Rank companies and categories using window functions

These steps surfaced patterns and concentrations in the data.

---

### 3. Visualization (Tableau)
Tableau was used to visualize and compare patterns identified through SQL, including:
- Layoffs by industry
- Layoffs by company stage
- Layoffs by funding level
- Layoffs by geographic region

Visualizations were used to support interpretation rather than infer causality.

---

## Challenges & Limitations
Several challenges were encountered during this analysis:

- The dataset is observational, limiting the ability to make causal claims about layoffs
- External variables such as macroeconomic conditions, interest rates, and company strategy
  are not captured in the data
- Some records contained missing or inconsistent values, requiring cleaning and standardization
- Layoff counts alone do not fully represent company impact without additional context
  such as total employee size

These limitations were acknowledged throughout the analysis, and conclusions were
intentionally framed as associations rather than causes.

---

## Key Insights
- Certain industries are more strongly associated with higher layoff counts
- Company stage and funding level show distinct layoff patterns
- Some factors appear to influence layoffs more frequently, but none can be isolated as causal

---

## Repository Structure
## Link to Tableau Dashboard (https://public.tableau.com/app/profile/mazino.onowakpokpo/viz/eda_layoffs_dashboard/Dashboard1?publish=yes)
