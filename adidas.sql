/*
===============================================
ADIDAS SALES ANALYSIS PROJECT
===============================================

This project analyzes Adidas' sales data to extract valuable business insights:
- Sales performance metrics: revenue, profit, transaction volume
- Regional and state-level sales contributions
- Product performance by channel and geography
- Temporal sales trends (monthly, yearly)
- Data quality checks and cleaning

Major stages of analysis:
1. Data exploration and quality checks
2. Data cleaning and standardization
3. Metric computation
4. Multidimensional performance analysis
5. Trend and ranking reports
*/

-- ===================
-- DATABASE SETUP
-- ===================
USE adidas;

-- Disable safe update mode for cleaning operations
SET SQL_SAFE_UPDATES = 0;

-- ==========================
-- 1. DATA EXPLORATION
-- ==========================

-- Preview dataset
SELECT * FROM adidas LIMIT 5;

-- Inspect data types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'adidas' AND TABLE_NAME = 'adidas';

-- ===================================
-- 2. DATA QUALITY & VALIDATION CHECKS
-- ===================================

-- Check distinct values in categorical columns
SELECT DISTINCT(Retailer) FROM adidas;
SELECT DISTINCT(Region) FROM adidas;
SELECT DISTINCT(State) FROM adidas;
SELECT DISTINCT(City) FROM adidas;
SELECT DISTINCT(Product) FROM adidas;
SELECT DISTINCT(`Sales Method`) FROM adidas;

-- Validate numeric fields for formatting issues
SELECT `Units Sold` FROM adidas WHERE `Units Sold` NOT REGEXP '^[0-9]+$';
SELECT `Total Sales` FROM adidas WHERE `Total Sales` NOT REGEXP '^[0-9]+$';
SELECT `Price per Unit` FROM adidas WHERE `Price per Unit` NOT REGEXP '^[0-9]+$';
SELECT `Operating Profit` FROM adidas WHERE `Operating Profit` NOT REGEXP '^[0-9]+$';

-- =====================
-- 3. DATA CLEANING
-- =====================

-- Standardize and clean numeric fields
UPDATE adidas
SET 
    `Price per Unit` = REPLACE(`Price per Unit`, '$', ''),
    `Price per Unit` = REPLACE(`Price per Unit`, '.', '')/100,
    `Total Sales` = REPLACE(`Total Sales`, '$', ''),
    `Operating Profit` = REPLACE(`Operating Profit`, '$', ''),
    `Units Sold` = REPLACE(`Units Sold`, ',', ''),
    `Total Sales` = REPLACE(`Total Sales`, ',', ''),
    `Operating Profit` = REPLACE(`Operating Profit`, ',', ''),
    `Operating Margin` = REPLACE(`Operating Margin`, '%', '');

-- ===============================
-- 4. DUPLICATE RECORD IDENTIFIER
-- ===============================

-- Identify duplicate transactions
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

-- =============================
-- 5. CORE BUSINESS METRICS
-- =============================

-- Total profit
SELECT ROUND(SUM(`Operating Margin`), 2) AS Total_profit FROM adidas;

-- Total sales (revenue)
SELECT ROUND(SUM(`Total Sales`), 2) AS Total_sales FROM adidas;

-- Number of transactions
SELECT COUNT(`Invoice Date`) AS Count_transactions FROM adidas;

-- Date range of sales
SELECT 
    MIN(`Invoice Date`) AS Start_date,
    MAX(`Invoice Date`) AS End_date
FROM adidas;

-- Average profit margin
SELECT ROUND(AVG(`Operating Margin`), 2) AS Average_profit FROM adidas;

-- ================================
-- 6. SALES CHANNEL PERFORMANCE
-- ================================

-- Summary by Sales Method
SELECT 
    `Sales Method`,
    COUNT(*) AS Num_Orders,
    SUM(`Operating Profit`) AS Profit,
    SUM(`Total Sales`) AS Revenue,
    ROUND(SUM(`Operating Profit`) * 100.0 / NULLIF(SUM(`Total Sales`), 0), 2) AS Profit_Percent,
    ROUND(SUM(`Total Sales`) * 100.0 / (SELECT SUM(`Total Sales`) FROM adidas), 2) AS Revenue_Percent
FROM adidas
GROUP BY `Sales Method`
ORDER BY Revenue DESC;

-- Summary by Retailer
SELECT 
    Retailer,
    COUNT(*) AS Num_Orders,
    SUM(`Operating Profit`) AS Profit,
    SUM(`Total Sales`) AS Revenue,
    ROUND(SUM(`Operating Profit`) * 100.0 / NULLIF(SUM(`Total Sales`), 0), 2) AS Profit_Percent,
    ROUND(SUM(`Total Sales`) * 100.0 / (SELECT SUM(`Total Sales`) FROM adidas), 2) AS Revenue_Percent
FROM adidas
GROUP BY Retailer
ORDER BY Revenue DESC;

-- ====================================
-- 7. PRODUCT PERFORMANCE ANALYSIS
-- ====================================

-- Top 3 products by sales method
WITH Ranked_Products AS (
    SELECT 
        `Sales Method`,
        Product,
        COUNT(*) AS Order_Num,
        SUM(`Total Sales`) AS Revenue,
        ROUND(AVG(`Operating Margin`), 2) AS Avg_Profit,
        SUM(`Operating Profit`) AS Profit,
        DENSE_RANK() OVER (
            PARTITION BY `Sales Method` 
            ORDER BY SUM(`Total Sales`) DESC
        ) AS Cur_rank
    FROM adidas
    GROUP BY `Sales Method`, Product
)
SELECT 
    `Sales Method`, Product, Order_Num, Avg_Profit, Profit, Revenue
FROM Ranked_Products
WHERE Cur_rank <= 3
ORDER BY Revenue DESC;

-- Product-wide performance summary
SELECT 
    Product,
    SUM(`Units Sold`) AS Sold_Num,
    SUM(`Operating Profit`) AS Profit,
    SUM(`Total Sales`) AS Revenue,
    ROUND(SUM(`Operating Profit`) * 100.0 / NULLIF(SUM(`Total Sales`), 0), 2) AS Profit_Percent
FROM adidas
GROUP BY Product
ORDER BY Revenue DESC;

-- ================================
-- 8. REGIONAL SALES PERFORMANCE
-- ================================

-- Revenue and profit by region
SELECT 
    Region,
    SUM(`Operating Profit`) AS Profit,
    SUM(`Total Sales`) AS Revenue,
    ROUND(SUM(`Operating Profit`) * 100.0 / NULLIF(SUM(`Total Sales`), 0), 2) AS Profit_Percent
FROM adidas
GROUP BY Region
ORDER BY Revenue DESC;

-- =========================
-- 9. STATE-LEVEL INSIGHTS
-- =========================

-- Performance by state
WITH Total_Order_Count AS (
    SELECT COUNT(*) AS Order_Counts FROM adidas
),
Total_Revenue AS (
    SELECT SUM(`Total Sales`) AS Total_Sales FROM adidas
)
SELECT 
    State,
    COUNT(*) AS Num_Orders,
    ROUND(COUNT(*) / (SELECT Order_Counts FROM Total_Order_Count), 2)*100 AS Order_Percent,
    ROUND(AVG(`Operating Margin`), 2) AS Avg_Profit,
    SUM(`Total Sales`) AS Revenue,
    SUM(`Operating Profit`) AS Profit,
    ROUND(SUM(`Total Sales`) / (SELECT Total_Sales FROM Total_Revenue), 2)*100 AS Revenue_Percent
FROM adidas
GROUP BY State
ORDER BY Revenue DESC;

-- State performance in the 'West' region
SELECT 
    State,
    COUNT(*) AS Num_Orders,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM adidas WHERE Region = 'West'), 2)*100 AS Order_Percent,
    ROUND(AVG(`Operating Margin`), 2) AS Avg_Profit,
    SUM(`Total Sales`) AS Revenue,
    SUM(`Operating Profit`) AS Profit,
    ROUND(SUM(`Total Sales`) / (SELECT SUM(`Total Sales`) FROM adidas WHERE Region = 'West'), 2)*100 AS Revenue_Percent
FROM adidas
WHERE Region = 'West'
GROUP BY State
ORDER BY Revenue DESC;

-- ===============================
-- 10. TEMPORAL (MONTHLY/YEARLY) TRENDS
-- ===============================

-- Monthly sales overview
SELECT 
    MONTH(`Invoice Date`) AS Month,
    COUNT(*) AS Num_Orders,
    SUM(`Units Sold`) AS Num_Pieces,
    SUM(`Operating Profit`) AS Profit,
    ROUND(AVG(`Operating Margin`), 2) AS Avg_Profit,
    SUM(`Total Sales`) AS Revenue
FROM adidas
GROUP BY Month
ORDER BY Revenue DESC;

-- Monthly revenue with MoM % change
WITH MonthlySales AS (
    SELECT 
        MONTH(`Invoice Date`) AS Month,
        COUNT(*) AS Num_Orders,
        SUM(`Units Sold`) AS Num_Pieces,
        SUM(`Operating Profit`) AS Profit,
        SUM(`Total Sales`) AS Revenue,
        LAG(SUM(`Total Sales`)) OVER (ORDER BY MIN(`Invoice Date`)) AS Prev_Revenue,
        ROUND((SUM(`Total Sales`) - LAG(SUM(`Total Sales`)) OVER (ORDER BY MIN(`Invoice Date`))) * 100.0 / 
              NULLIF(LAG(SUM(`Total Sales`)) OVER (ORDER BY MIN(`Invoice Date`)), 0), 2) AS MoM_Change_Percent
    FROM adidas
    GROUP BY Month
)
SELECT * FROM MonthlySales
ORDER BY Revenue DESC;

-- Online sales by month (MoM trends)
WITH MonthlySales AS (
    SELECT 
        YEAR(`Invoice Date`) AS Year,
        MONTH(`Invoice Date`) AS Month,
        COUNT(*) AS Num_Orders,
        SUM(`Units Sold`) AS Num_Pieces,
        SUM(`Operating Profit`) AS Profit,
        SUM(`Total Sales`) AS Revenue,
        LAG(SUM(`Total Sales`)) OVER (ORDER BY YEAR(`Invoice Date`), MONTH(`Invoice Date`)) AS Prev_Revenue,
        ROUND((SUM(`Total Sales`) - LAG(SUM(`Total Sales`)) OVER (ORDER BY YEAR(`Invoice Date`), MONTH(`Invoice Date`))) * 100.0 / 
              NULLIF(LAG(SUM(`Total Sales`)) OVER (ORDER BY YEAR(`Invoice Date`), MONTH(`Invoice Date`)), 0), 2) AS MoM_Change_Percent
    FROM adidas
    WHERE `Sales Method` = 'online'
    GROUP BY Year, Month
)
SELECT * FROM MonthlySales
ORDER BY Revenue DESC;

-- Yearly sales summary
SELECT 
    YEAR(`Invoice Date`) AS Year,
    COUNT(*) AS Num_Orders,
    SUM(`Operating Profit`) AS Profit,
    ROUND(AVG(`Operating Margin`), 2) AS Avg_Profit,
    SUM(`Total Sales`) AS Revenue
FROM adidas
GROUP BY Year
ORDER BY Revenue DESC;

-- ===============================
-- 11. REGIONAL RANKING ANALYSIS
-- ===============================

-- Regional overview with ranking
WITH Total_Order_Count AS (
    SELECT COUNT(*) AS Order_Counts FROM adidas
),
Total_Revenue AS (
    SELECT SUM(`Total Sales`) AS Total_Sales FROM adidas
)
SELECT 
    Region,
    COUNT(*) AS Num_Orders,
    ROUND(COUNT(*) / (SELECT Order_Counts FROM Total_Order_Count), 2)*100 AS Order_Percent,
    ROUND(AVG(`Operating Margin`), 2) AS Avg_Profit,
    SUM(`Total Sales`) AS Revenue,
    SUM(`Operating Profit`) AS Profit,
    ROUND(SUM(`Total Sales`) / (SELECT Total_Sales FROM Total_Revenue), 2)*100 AS Revenue_Percent
FROM adidas
GROUP BY Region
ORDER BY Revenue DESC;

-- Top 3 states per region
WITH Ranked_Region AS (
    SELECT 
        Region,
        State,
        COUNT(*) AS Order_Num,
        SUM(`Total Sales`) AS Revenue,
        ROUND(AVG(`Operating Margin`), 2) AS Avg_Profit,
        SUM(`Operating Profit`) AS Profit,
        DENSE_RANK() OVER (PARTITION BY Region ORDER BY SUM(`Total Sales`) DESC) AS cur_Rank
    FROM adidas
    GROUP BY Region, State
)
SELECT 
    Region, State, Order_Num, Avg_Profit, Profit, Revenue
FROM Ranked_Region
WHERE cur_Rank <= 3
ORDER BY Revenue DESC;

-- ============================
-- RE-ENABLE SAFE MODE
-- ============================
SET SQL_SAFE_UPDATES = 1;
