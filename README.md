# sql-sales-eda
End-to-end SQL exploratory analysis of sales data with revenue metrics, customer insights, and data quality validation.

# Sales Data Exploratory Analysis (SQL)

# Project Overview
This project performs an end-to-end exploratory data analysis (EDA) on transactional sales data using SQL. The goal is to understand revenue performance, customer behavior, and product trends while validating data integrity and metric correctness.
The analysis emphasizes correct aggregation logic, join validation, and business-ready insights, reflecting real-world analytics workflows.

# Dataset Description
The dataset consists of three relational tables:
1. sales: Transaction-level order data including quantities, dates, and customer/product keys
2. customers: Customer demographic and geographic information
3. products: Product hierarchy, categories, and pricing data
These tables follow a star schema–like structure, with sales as the fact table and customers and products as dimensions.

# Business Questions
Key questions addressed in this analysis include:
1. What is the total revenue and order volume of the business?
2. Which product categories and subcategories generate the most revenue?
3. Who are the top revenue-generating customers?
4. How concentrated is revenue across customers and products?
5. Are there any data quality issues that could affect KPI accuracy?

# Data Preparation & Cleaning
1. Renamed columns for consistency and usability
2. Converted string-based dates into proper DATE formats
3. Cleaned currency fields and converted prices to numeric types
4. Standardized naming conventions across tables
All transformations are documented and executed prior to analysis to ensure reliable results.

# Data Quality Checks
Before calculating revenue metrics, a validation check was performed to confirm referential integrity between sales and products.
1. Verified that all sales records have matching product records
2. Confirmed zero unmatched product keys in the sales table
3. Ensured INNER JOINs could be safely used without losing revenue data
This step prevents silent data loss and inaccurate aggregations.

# Key Metrics & Analysis
The analysis calculates and explores:
1. Total revenue, total orders, total customers, and total products
2. Revenue by category, subcategory, and product
3. Top and bottom performing products
4. Revenue distribution across customers
5. Geographic distribution of customers and sold items
A consolidated KPI summary report is included for high-level business visibility.

# Insights & Findings
1. Revenue is highly concentrated, with a small subset of customers generating a significant share of total sales.
2. Product categories show clear performance differences, indicating opportunities for category-specific strategies.
3. Data validation confirmed complete product coverage in sales, ensuring accurate revenue aggregation.
4. Several products and subcategories consistently underperform, highlighting potential candidates for optimization or discontinuation.

# Assumptions & Limitations
1. Revenue is calculated using listed unit prices and does not account for discounts or promotions.
2. Customer behavior analysis assumes customer records represent unique individuals.
3. The dataset does not include time-based cost changes or returns.
4. An initial comparison showed customers with orders exceeding total customers. This discrepancy was investigated and traced to SQL aggregation logic rather than source data. Validation checks confirmed zero unmatched customer or product keys, and corrected metrics were used for all final analyses.

# What I’d Do in Production
1. Enforce foreign key constraints between fact and dimension tables
2. Automate data quality checks as part of ETL pipelines
3. Create incremental models for revenue metrics (dbt-style)
4. Expose KPIs through a BI dashboard for stakeholder consumption

# Tools Used
1. SQL (MySQL)
2. Relational data modeling concepts
3. Exploratory data analysis techniques
