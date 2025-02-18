/*
ADIDAS SALES ANALYSIS PROJECT

This project analyzes Adidas' sales data to uncover business insights, including:
- Sales performance metrics (revenue, profit, transaction volume)
- Regional and state-level sales breakdowns
- Product performance across sales channels
- Temporal sales trends (monthly/yearly)
- Data quality assurance and cleaning

Key components:
1. Data exploration and quality checks
2. Data cleaning and standardization
3. Core business metrics calculation
4. Multidimensional performance analysis
5. Ranking and trend analysis
*/

-- ###############
-- # DATA SETUP #
-- ###############
USE adidas;

-- Disable safe update mode for bulk operations
SET SQL_SAFE_UPDATES = 0;

-- #####################
-- # DATA EXPLORATION #
-- #####################

-- Initial data inspection
SELECT * FROM adidas LIMIT 5;

-- Verify column data types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'adidas' AND TABLE_NAME = 'adidas';

-- ####################
-- # DATA QUALITY CHECKS #
-- ####################

-- Check for data consistency in categorical columns
SELECT DISTINCT(Retailer) FROM adidas;
SELECT DISTINCT(Region) FROM adidas;
SELECT DISTINCT(State) FROM adidas;
SELECT DISTINCT(City) FROM adidas;
SELECT DISTINCT(Product) FROM adidas;
SELECT DISTINCT(`Sales Method`) FROM adidas;

-- Validate numeric field formats
SELECT `Units Sold` FROM adidas WHERE `Units Sold` NOT REGEXP '^[0-9]+$';
SELECT `Total Sales` FROM adidas WHERE `Total Sales` NOT REGEXP '^[0-9]+$';
SELECT `Price per Unit` FROM adidas WHERE `Price per Unit` NOT REGEXP '^[0-9]+$';
SELECT `Operating Profit` FROM adidas WHERE `Operating Profit` NOT REGEXP '^[0-9]+$';

-- ################
-- # DATA CLEANING #
-- ################

-- Standardize numeric formats
UPDATE adidas
SET 
    `Price per Unit` = REPLACE(`Price per Unit`, '$', ''),
    `Price per Unit` = REPLACE(`Price per Unit`, '.', '')/100,  -- Convert to decimal
    `Total Sales` = REPLACE(`Total Sales`, '$', ''),
    `Operating Profit` = REPLACE(`Operating Profit`, '$', ''),
    `Units Sold` = REPLACE(`Units Sold`, ',', ''),
    `Total Sales` = REPLACE(`Total Sales`, ',', ''),
    `Operating Profit` = REPLACE(`Operating Profit`, ',', ''),
    `Operating Margin` = REPLACE(`Operating Margin`, '%', '');

-- #########################
-- # DUPLICATE IDENTIFICATION #
-- #########################

-- Find duplicate transactions
SELECT 
    `Invoice Date`, `Retailer ID`, Region, State, City, Product, 
    `Price per Unit`, `Units Sold`, `Total Sales`, `Operating Profit`, 
    `Operating Margin`, `Sales Method`,
    COUNT(*) AS ROW_NUM
FROM adidas
GROUP BY 
    `Invoice Date`, `Retailer ID`, Region, State, City, Product, 
    `Price per Unit`, `Units Sold`, `Total Sales`, `Operating Profit`, 
    `Operating Margin`, `Sales Method`
HAVING ROW_NUM > 1;

-- ##############################
-- # CORE BUSINESS METRICS #
-- ##############################

-- Total Profit Calculation
SELECT ROUND(SUM(`Operating Margin`),2) AS Total_profit FROM adidas;

-- Total Revenue Calculation
SELECT ROUND(SUM(`Total Sales`),2) AS Total_sales FROM adidas;

-- Transaction Volume Analysis
SELECT COUNT(`Invoice Date`) AS Count_transactions FROM adidas;

-- Sales Date Range
SELECT 
    MIN(`Invoice Date`) AS Start_date,
    MAX(`Invoice Date`) AS end_date
FROM adidas;

-- Average Profit Margin
SELECT ROUND(AVG(`Operating Margin`),2) AS AVERAGE_profit FROM adidas;

-- ############################
-- # SALES CHANNEL ANALYSIS #
-- ############################

-- Sales Method Performance
SELECT 
    `SALES METHOD`,
    COUNT(*) AS NUM_ORDERS,
    ROUND(AVG(`Operating Margin`),2) AS AVG_PROFIT,
    SUM(`Operating Profit`) AS PROFIT,
    SUM(`TOTAL SALES`) AS REVENUE
FROM adidas
GROUP BY `SALES METHOD`
ORDER BY REVENUE DESC;

-- ########################
-- # PRODUCT PERFORMANCE #
-- ########################

-- Top Products by Sales Channel
WITH Ranked_Products AS (
    SELECT 
        `SALES METHOD`,
        Product,
        COUNT(*) AS ORDER_NUM,
        SUM(`TOTAL SALES`) AS REVENUE,
        ROUND(AVG(`Operating Margin`),2) AS AVG_PROFIT,
        SUM(`Operating Profit`) AS PROFIT,
        DENSE_RANK() OVER (
            PARTITION BY `SALES METHOD` 
            ORDER BY SUM(`TOTAL SALES`) DESC
        ) AS RANKS
    FROM adidas
    GROUP BY `SALES METHOD`, Product
)
SELECT 
    `SALES METHOD`, 
    Product, 
    ORDER_NUM,
    AVG_PROFIT,
    PROFIT,
    REVENUE
FROM Ranked_Products
WHERE RANKS <= 3
ORDER BY REVENUE DESC;

-- ##########################
-- # GEOGRAPHIC ANALYSIS #
-- ##########################

-- State-Level Performance
WITH TOTAL_ORDER_COUNT AS (
    SELECT COUNT(*) AS ORDER_COUNTS FROM adidas
),
TOTAL_REVENUE AS (
    SELECT SUM(`TOTAL SALES`) AS SALES FROM adidas
)
SELECT 
    State,
    COUNT(*) AS NUM_ORDERS,
    ROUND(COUNT(*) / (SELECT ORDER_COUNTS FROM TOTAL_ORDER_COUNT), 2)*100 AS PERCENT,
    ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
    SUM(`TOTAL SALES`) AS REVENUE,
    SUM(`Operating Profit`) AS PROFIT,
    ROUND(SUM(`TOTAL SALES`) / (SELECT SALES FROM TOTAL_REVENUE), 2)*100 AS REV_PERCENT
FROM adidas
GROUP BY State
ORDER BY REVENUE DESC;

-- ########################
-- # TEMPORAL ANALYSIS #
-- ########################

-- Monthly Sales Trends
SELECT 
    MONTH(`Invoice Date`) AS MONTH,
    COUNT(*) AS NUM_ORDERS,
    SUM(`Operating Profit`) AS PROFIT,
    ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
    SUM(`TOTAL SALES`) AS REVENUE
FROM adidas
GROUP BY MONTH
ORDER BY REVENUE DESC;

-- Yearly Sales Trends
SELECT 
    YEAR(`Invoice Date`) AS YEAR,
    COUNT(*) AS NUM_ORDERS,
    SUM(`Operating Profit`) AS PROFIT,
    ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
    SUM(`TOTAL SALES`) AS REVENUE
FROM adidas
GROUP BY YEAR
ORDER BY REVENUE DESC;

-- ###########################
-- # REGIONAL ANALYSIS #
-- ###########################

-- Regional Performance Breakdown
WITH TOTAL_ORDER_COUNT AS (
    SELECT COUNT(*) AS ORDER_COUNTS FROM adidas
),
TOTAL_REVENUE AS (
    SELECT SUM(`TOTAL SALES`) AS SALES FROM adidas
)
SELECT 
    Region,
    COUNT(*) AS NUM_ORDERS,
    ROUND(COUNT(*) / (SELECT ORDER_COUNTS FROM TOTAL_ORDER_COUNT), 2)*100 AS ORD_NUM_PERCENT,
    ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
    SUM(`TOTAL SALES`) AS REVENUE,
    SUM(`Operating Profit`) AS PROFIT,
    ROUND(SUM(`TOTAL SALES`) / (SELECT SALES FROM TOTAL_REVENUE), 2)*100 AS REV_PERCENT
FROM adidas
GROUP BY Region
ORDER BY REVENUE DESC;

-- Top States by Region
WITH Ranked_region AS (
    SELECT 
        Region,
        State,
        COUNT(*) AS ORDER_NUM,
        SUM(`TOTAL SALES`) AS REVENUE,
        ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
        SUM(`Operating Profit`) AS PROFIT,
        DENSE_RANK() OVER (
            PARTITION BY Region 
            ORDER BY SUM(`TOTAL SALES`) DESC
        ) AS RANKS
    FROM adidas
    GROUP BY Region, State
)
SELECT 
    Region,
    State,
    ORDER_NUM,
    AVG_PROFIT,
    PROFIT,
    REVENUE
FROM Ranked_region
WHERE RANKS <= 3
ORDER BY REVENUE DESC;

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;