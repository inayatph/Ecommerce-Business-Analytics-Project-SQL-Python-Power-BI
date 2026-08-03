# Urban Nest Retail - End to End Business Analytics Project
Sales, Customer, and Demand Forecasting Analytics for an Ecommerce Retailer 

<img width="923" height="525" alt="image" src="https://github.com/user-attachments/assets/53265bcf-0664-46a0-b49e-b935e8868b90" />






## 1. Business Problem

**Urban Nest Retail** is a fictional multi-category ecommerce company (Furniture, Office Supplies, Home Décor, Electronics Accessories) simulating ₹340 Cr in annual revenue with a hybrid B2C/B2B model. Despite 51.57% YoY revenue growth, gross margin compressed from 10% to 11%, and leadership had no unified view of **why**.

**This project answers four questions the business could not answer with scattered spreadsheets:**
1. Where is margin actually being lost — discounting, returns, or category mix?
2. Which customers are worth retaining, and which regions deserve further investment?
3. What will demand look like over the next 12 months?

## 2. Project Architecture

Raw Data (Kaggle: Global Superstore — Orders, Returns, People)
        │
        ▼
Python — Cleaning, Feature Engineering, RFM / CLV / ABC Analysis
        │
        ▼
MySQL — Star Schema (4 Fact + 4 Dimension Tables, Enforced PK/FK)
        │
        ▼
SQL Analysis Layer — 20 business queries, views, stored procedures
        │
        ▼
Power BI — Star schema model, 30 DAX measures, 3-page executive dashboard
        │
        ▼
Business Insights & CEO-style Presentation



## 3. Tech Stack

| Layer | Tools |
|---|---|
| Data Cleaning & Feature Engineering | Python (Pandas, NumPy), Jupyter Notebook |
| Database & Analysis | MySQL |
| Visualization | Power BI Desktop, Matplotlib |
| Version Control | Git / GitHub |


## 4. Key Highlights

- **Star schema data model** in MySQL with enforced primary/foreign keys — 4 fact tables, 4 dimension tables, ~46 columns, built from raw Kaggle data through a documented Python cleaning pipeline
- **RFM Segmentation & CLV** — customers scored on Recency/Frequency/Monetary and segmented into 6 behavioral groups (Champions, Loyal, At Risk, Lost, etc.)
- **ABC Product Classification** — Pareto analysis identifying the SKUs driving the majority of revenue, visualized live in Power BI via a cumulative-contribution measure
- **30 production DAX measures** across sales, true margin, time intelligence, ranking, and customer value tiers
- **3-page executive Power BI dashboard** — Executive Overview (decomposition tree, conditional-formatted matrix), Sales & Product Analytics (Pareto chart, trendline scatter, drillthrough), Customer Analytics (RFM treemap, CLV distribution)
- **48 documented business insights**, each following a Finding → So What → Recommendation structure
- **CEO-style presentation deck** translating the analysis into a board-ready business case with ROI framing

## 5. About This Project

Built as an end-to-end portfolio project simulating the real workflow of a Data Analyst at an Indian ecommerce company — from raw data to a CEO-ready business case, covering SQL, Python, statistical forecasting, and Power BI.

**Author:** Inayat P H | phinayat@gmail.com | www.linkedin.com/in/inayat2001
 
