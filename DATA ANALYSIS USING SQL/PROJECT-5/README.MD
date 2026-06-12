# 🛒 Zepto E-commerce SQL Project

## Overview

This project focuses on analyzing product and inventory data from Zepto, an online grocery delivery platform. The analysis was performed using SQL to explore the dataset, clean inconsistencies, and generate business insights that can support decision-making related to pricing, inventory management, and category performance.

The project demonstrates practical SQL skills, including data exploration, data cleaning, aggregation, conditional logic, and business-oriented reporting.

Objectives:-

Explore the Zepto product dataset to understand its structure and quality.
Identify and resolve data issues that could affect analysis.
Analyze stock availability and product distribution.
Evaluate discount strategies across different product categories.
Estimate category-wise revenue potential.
Discover high-value products and pricing patterns.
Generate inventory insights that can assist operational planning.
Dataset Information

The project uses a table named zepto, containing product-level information.

Table Schema:-

Column Name	 Data Type  	Description
sku_id	SERIAL (Primary Key) Unique product identifier
category	VARCHAR(400)	 Product category
name	VARCHAR(100)	 Product name
mrp	INTEGER 	Maximum Retail Price
discount_percent	INTEGER 	Discount percentage offered   
available_quantity	INTEGER 	Available stock quantity
discounted_selling_price	INTEGER / NUMERIC	 Selling price after discount
weight_in_gms	INTEGER	 Product weight in grams
out_of_stock	BOOLEAN	 Stock availability status
quantity	INTEGER  	Product quantity/unit count

Technologies Used:-

PostgreSQL
SQL
Data Exploration Techniques
Data Cleaning Operations
Aggregation and Analytical Queries

Project Workflow:-

1. Database Setup
Created the zepto table.
Defined appropriate data types and constraints.
Assigned sku_id as the primary key.

2. Data Exploration

The following exploratory analyses were performed:

Counted the total number of records.
Retrieved sample records for inspection.
Identified rows containing null values.
Listed all unique product categories.
Measured stock availability distribution.
Detected products appearing under multiple SKUs.

3. Data Cleaning

Several cleaning steps were applied to improve data quality:

Removing Invalid Pricing Records

Products having an MRP equal to zero were identified and removed.

DELETE FROM zepto
WHERE mrp = 0;
Price Conversion

The pricing data was originally stored in paise and converted into rupees.

UPDATE zepto
SET mrp = mrp / 100.0,
    discounted_selling_price = discounted_selling_price / 100.0;
Data Type Optimization

The discounted selling price column was modified to support decimal precision.

ALTER TABLE zepto
ALTER COLUMN discounted_selling_price
TYPE NUMERIC(8,2);
Business Insights Generated
Top Discounted Products

Identified products offering the highest discount percentages.

Purpose: Understand aggressive promotional strategies and value offerings.

High-MRP Products That Are Out of Stock

Filtered expensive products that were unavailable.

Purpose: Detect potential revenue loss due to stock shortages.

Category-wise Revenue Estimation

Estimated revenue using:

Discounted Selling Price × Available Quantity

Purpose: Determine categories contributing the highest inventory value.

Premium Products with Minimal Discounts

Analyzed products satisfying:

MRP greater than ₹500
Discount less than 10%

Purpose: Identify premium products maintaining pricing power.

Categories with Highest Average Discounts

Calculated average discounts across categories.

Purpose: Evaluate category-specific pricing strategies.

Price per Gram Analysis

Computed the cost efficiency of products weighing more than 100 grams.

Formula:

Price per Gram = Discounted Selling Price ÷ Weight

Purpose: Identify products offering better value to customers.

Product Weight Segmentation

Grouped products into weight categories using CASE statements.

Categories used:

Low
Medium
Bulk

Purpose: Support packaging and inventory segmentation analyses.

Total Inventory Weight by Category

Calculated the total stock weight held within each category.

Formula:

Weight × Available Quantity

Purpose: Understand warehouse space requirements and inventory distribution.

Key SQL Concepts Demonstrated

CREATE TABLE
SELECT
DISTINCT
GROUP BY
HAVING
ORDER BY
CASE WHEN
Aggregate Functions:
COUNT()
SUM()
AVG()
ROUND()
Filtering with WHERE
Data Modification:
UPDATE
DELETE
ALTER TABLE
Potential Business Impact

The analysis can help Zepto stakeholders:

Optimize discount strategies.
Monitor inventory shortages.
Improve category-level planning.
Identify high-value products.
Enhance revenue forecasting.
Support inventory management decisions.
Future Enhancements
Build interactive dashboards using Power BI or Tableau.
Perform time-series sales analysis using transactional data.
Develop inventory replenishment recommendations.
Apply predictive analytics to forecast demand patterns.
Integrate customer purchase behavior for deeper insights.

**Conclusion**

This project showcases how SQL can be used not only for querying data but also for transforming raw retail datasets into actionable business intelligence. Through systematic exploration, cleaning, and analytical querying, the project provides meaningful insights into Zepto's product portfolio, inventory status, and pricing strategies.

Author: TANMAYTA AGRAWAL
Project: Zepto Sales Analysis Using SQL
Database: PostgreSQL

