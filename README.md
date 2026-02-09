# Portfolio Project: E-commerce Business Optimization
## Strategic Data Analysis & Growth Optimization (Nordcart)

### 📊 Executive Summary
This project demonstrates an end-to-end data analytics workflow for **Nordcart**, a synthetic e-commerce retailer. Leveraging **PostgreSQL** and **Business Intelligence** principles, I solved three critical business challenges: budget reallocation for profit maximization, retention strategies for holiday cohorts, and determining the **True Value of Marketing Channels** (distinguishing between new sales and existing organic traffic).

**The "Quality-First" Difference**: With 4 years of experience in Quality Assurance (QA), I approached this project with a rigorous "Data Integrity" mindset—ensuring that the insights are not just visually appealing, but mathematically sound and validated against edge cases.

---

### 📂 Project Structure
```text
├── 1.NordCart_Executive_Summary.pbix  # Power BI Dashboard
├── 2.Executive_Summary_Findings.md     # Stakeholder Report (Recommendations)
├── COMPANY_BACKGROUND.md               # Context & Business Model
├── Data_Quality_Report.md              # QA Validation Layer
├── PROJECT_RESUME_NARRATIVE.md         # Interview Guide & Resume Context
├── important_concepts.md               # Analytical Deep-Dive (ELI5)
├── sql_views_for_powerbi.sql           # Database Modeling (Star Schema)
├── sql_problemStatement001.sql         # Budget Reallocation Logic
├── sql_problemStatement002.sql         # Retention & Cohort Logic
└── sql_problemStatement003.sql         # Incrementality & Audit Logic
```

---

### 🛠️ The Tech Stack
- **Database**: PostgreSQL (Data Modeling, Advanced SQL, CTEs, Window Functions)
- **Visualization**: Power BI (Star Schema, Complex DAX, Scenario Modeling)
- **Methodology**: 
    - **Cohort Analysis**: Grouping users by their "signup month" to track loyalty over time.
    - **Attribution Modeling**: Dividing marketing costs across categories for true profit calculation.
    - **Incrementality Auditing**: Suppression analysis to identify cannibalized vs. reactivated revenue.

---

### 🎯 Business Challenges & Insights

#### 1. Profit-Driven Budget Reallocation
> "Electronics accounts for 55% of revenue but has low margins (15%), while Fashion yields 60% margins. How would a $50k 'Paid Search' budget shift impact net profit?"
- **💡 Insight**: Shifting spend based on **POAS (Profit on Ad Spend)** rather than ROAS projected a **$165k lift** in net profit.
- **SQL Source**: [sql_problemStatement001.sql](sql_problemStatement001.sql)

#### 2. Holiday Retention & Reactivation
> "Revenue drops 50% post-Q4. Which channel produces the stickiest customers?"
- **💡 Insight**: Identifed that **Fashion-Heavy buyers double their value ($110 → $251)** post-holiday, making them the priority for Q1 retention campaigns.
- **SQL Source**: [sql_problemStatement002.sql](sql_problemStatement002.sql)

#### 3. Real Marketing Value (Incrementality)
> "Email shows 171+ ROAS, but is it just taking credit for Organic sales?"
- **💡 Insight**: Audit revealed that **86.2%** of Email revenue is **True Reactivation**, while only 4.9% is cannibalized from existing organic traffic.
- **SQL Source**: [sql_problemStatement003.sql](sql_problemStatement003.sql)

---

### 🛡️ Data Quality Assurance (DQA)
Because of my QA background, I built a [Data Quality Report](Data_Quality_Report.md) that documents how I cross-validated SQL logic against dashboard metrics to ensure 100% truth anchoring.

---

### 📬 Contact & Career
I am a Data Analyst with a passion for bridging the gap between technical QA and strategic business growth.
- **LinkedIn**: [Your LinkedIn Profile](https://linkedin.com/in/yourprofile)
- **Email**: [your.email@example.com]
- **Portfolio**: [Back to GitHub](https://github.com/yourusername)

