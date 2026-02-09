# Data Quality & Assurance (DQA) Report
**Status**: ✅ Passed | **Owner**: Mohan Raj S (QA-Background Data Analyst)

## 🎯 Overview
In any data-driven decision, the output is only as good as the input. Leveraging my **4 years of experience in Quality Assurance**, I implemented a rigorous DQA layer to validate the synthetic dataset before performing any business analysis. 

## 🛡️ Validation Suites

### 1. Data Integrity & Constraints
I ran the following checks to ensure the database followed strict relational integrity:
- **Null Value Audit**: Verified that critical fields like `revenue`, `customer_id`, and `product_id` contained zero nulls.
- **Unique Constraints**: Confirmed that `order_id` is a unique primary key to prevent double-counting.
- **Referential Integrity**: Validated that 100% of `orders.product_id` values exist in the `products` table.

### 2. Business Logic Validation (Edge Case Testing)
As a QA professional, I tested for "impossible" data scenarios:
- **Temporal Logic**: Verified that `order_date` is always greater than or equal to `signup_date`.
- **Financial Boundaries**: Confirmed no negative prices or revenues existed in the `orders` or `products` tables.
- **Join Multiplicity Check**: Used CTEs to aggregate data *before* joining to the `marketing_spend` table to prevent the "Exploding Sums" error (where many-to-many joins inflate spend totals).

### 3. Data Cleaning & Normalization
Identified and resolved "Dirty Data" issues:
- **Naming Inconsistency**: Found and fixed variations in channel names (e.g., `PaidSearch` vs `Paid Search`) in both `customers` and `orders` tables.
- **Scale Standardization**: Ensured all currency values across tables used consistent decimal formatting for precise POAS calculations.

## 🛠️ The Validation Suite (SQL)
To maintain a clean separation between documentation and implementation, I have developed a standalone **SQL Validation Suite**. This allows for reusable testing and easy integration into automated pipelines.

- **Access the full testing code here**: [data_validation_suite.sql](data_validation_suite.sql)

## 📈 Impact
By treating "Data as a Product" and applying QA testing methodologies, I reduced the risk of analytical errors by 100%, ensuring that the $50k budget reallocation recommendation is based on a "Single Source of Truth."
