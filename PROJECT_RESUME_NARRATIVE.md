# 📄 Project Narrative & Resume Context: NordCart E-commerce Optimization

> **Project Goal**: To transform raw e-commerce data into a strategic advisor system, using SQL and Power BI to solve critical business leaks in profit, retention, and marketing attribution.

---

## 🚀 1. The "Elevator Pitch" (For Resume Summary)
"Developed an end-to-end business intelligence ecosystem for a mid-sized e-commerce retailer. Optimized the marketing budget by shifting focus from low-margin Electronics to high-efficiency Fashion, while auditing marketing attribution to separate genuine revenue from cannibalized organic traffic."

---

## 🛡️ 2. The QA Edge: "Data Integrity First"
*Leveraging 4 years of QA experience to ensure technical debt never reaches the dashboard.*
- **SQL Validation Suite**: Architected a pre-deployment validation layer to detect "Join Multiplicity" and "Phantom Year" bugs before they hit stakeholder reports.
- **Truth Anchoring**: Cross-validated SQL "Ground Truth" queries against Power BI DAX measures to ensure a 0% discrepancy rate across all KPIs.

---

## 🎯 3. Problem Statement 1: Profit over Revenue
**Objective**: Electronics drives 55% of revenue but has 15% margins. Fashion has 60% margins. How to reallocate \$50k spend?
- **Action**: Developed a **Revenue-Share Attribution model** in SQL to correctly distribute marketing costs without double-counting row-level data.
- **Breakthrough**: Built a **Self-Healing Simulation** in Power BI that dynamically calculates the "To-Be" profit impact of budget shifts using DAX scenario modeling.
- **Result**: Proved that shifting \$5k/month to Fashion increases Net Profit by \$X, revealing Fashion as the "Hero" category for sustainable growth.

---

## 🔄 4. Problem Statement 2: Solving the Q1 Seasonality Drop
**Objective**: Revenue drops 50% from Q4 (Holiday) to Q1. How to stabilize the dip?
- **Action**: Performed **Cohort Analysis** (90-day repeat rate) in PostgreSQL, segmenting customers into "Transactional" (Electronics) vs. "Brand Fans" (Fashion).
- **Breakthrough**: Created a **Retention Heatmap (Cohort Matrix)** in Power BI to visually pinpoint where shoppers "leaked" out of the funnel.
- **Result**: Identified that "Fashion-Heavy" buyers double their lifetime value (AOV \$110 → \$251) post-holiday, whereas Electronics buyers collapse by 50%.
- **Impact**: Shifted Q1 strategy toward "Surgical Reactivation" of the Fashion core, protecting margins during the seasonal low.

---

## 🎯 5. Problem Statement 3: Incrementality & The "ROAS Audit"
**Objective**: Email reports an amazing 171x ROAS. Is it real growth or just "stealing credit"?
- **Action**: Conducted a **Suppression Analysis** and "Time-Based Overlap" audit to distinguish between Reactivated users and Cannibalized sales.
- **Breakthrough**: Engineered a **"Truth Waterfall" Visual** in Power BI using a custom SQL Bridge Table to strip away "Fake Growth" and show the "True Incremental Lift."
- **Result**: Audit revealed that while **4.9%** of Email revenue was cannibalizing Organic search, the channel still delivered a massive **86.2% True Reactivation** lift, justifying continued (but targeted) investment.

---

## 🛠️ 6. Technical "Interview War Stories"
*Recruiters ask: "Tell me about a time you solved a complex technical problem."*

- **The "Phantom Year" Bug**: Fixed a temporal overlap bug where SQL week-start definitions (Monday vs. Sunday) created ghost 2022 data in Power BI. Solved by replacing `CALENDARAUTO()` with a DAX-anchored `CALENDAR()` function.
- **The Galaxy Schema**: Solved Many-to-Many relationship conflicts between "Orders" and "Marketing Spend" facts by implementing a **Channel-Bridge Dimension**, routing all filters through a central master-controller.
- **Demand Saturation Discovery**: Used a **Scatter Plot with Play Axis** to prove that Fashion hits "Diminishing Returns" after \$X spend, preventing the company from over-investing in a saturated category.

---

## 📈 7. Core Technical Stack Used
- **Database**: PostgreSQL (CTEs, Window Functions, Aggregate Views, Data Modeling)
- **Visualization**: Power BI (Star/Galaxy Schema, Complex DAX, Scenario Modeling, Custom Navigation)
- **Analysis**: Statistical Lift Analysis, Cohort Analysis, Incrementality Auditing.
