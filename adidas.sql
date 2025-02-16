USE adidas;

SET SQL_SAFE_UPDATES = 0;

SELECT * 
FROM adidas
LIMIT 5;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'adidas' AND TABLE_NAME = 'adidas';

-- Looking for Incorrect Typos
SELECT DISTINCT(Retailer)
FROM adidas ;

SELECT DISTINCT(Region)
FROM adidas ;

SELECT DISTINCT(State)
FROM adidas ;

SELECT DISTINCT(City)
FROM adidas ;

SELECT DISTINCT(Product)
FROM adidas ;

SELECT DISTINCT(`Sales Method`)
FROM adidas ;

SELECT DISTINCT(`Price per Unit`)
FROM adidas ;


-- Looking for inconsistencies in string data
SELECT `Units Sold`
FROM adidas
WHERE `Units Sold` NOT REGEXP '^[0-9]+$';

SELECT `Total Sales`
FROM adidas
WHERE `Total Sales` NOT REGEXP '^[0-9]+$';


SELECT `Price per Unit`
FROM adidas
WHERE `Price per Unit` NOT REGEXP '^[0-9]+$';


SELECT `Operating Profit`
FROM adidas
WHERE `Operating Profit` NOT REGEXP '^[0-9]+$';

-- reomve signs 
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



ALTER TABLE adidas
CHANGE COLUMN `Price per Unit` Unit_price INT,
CHANGE COLUMN `Units Sold` SOLD_UNITS INT,
CHANGE COLUMN `Total Sales` TOTAL_SOLD INT,
CHANGE COLUMN `Operating Profit` PROFIT INT;


 -- Finding duplicates
SELECT 
`Invoice Date` , `Retailer ID` ,Region,State,City, `Product`, `Price per Unit` , `Units Sold` , `Total Sales` , `Operating Profit` , `Operating Margin` , `Sales Method`,
COUNT(*) AS ROW_NUM
FROM adidas
GROUP BY `Invoice Date` , `Retailer ID` ,Region,State,City, `Product`, `Price per Unit` , `Units Sold` , `Total Sales` , `Operating Profit` , `Operating Margin` , `Sales Method`
HAVING ROW_NUM > 1;

-- Total reveue by Sales Method
SELECT `SALES METHOD` , 
COUNT(*) AS NUM_ORDERS,
ROUND(AVG(`Operating Margin`),2) AS AVG_PROFIT ,
SUM(`Operating Profit`) AS PROFIT ,
SUM(`TOTAL SALES`) AS  REVENUE
FROM adidas
GROUP BY `SALES METHOD` 
ORDER BY REVENUE DESC;

-- Top 3 BEST SELLING Prodducts BY SALES METHOD 
-- Create CTE for best products 
WITH Ranked_Products AS (
  SELECT 
    `SALES METHOD`,
    Product,
    COUNT(*) AS ORDER_NUM ,
    SUM(`TOTAL SALES`) AS REVENUE,
    ROUND(AVG(`Operating Margin`),2) AS AVG_PROFIT ,
    SUM(`Operating Profit`) AS PROFIT ,
    DENSE_RANK() OVER (PARTITION BY `SALES METHOD` ORDER BY SUM(`TOTAL SALES`) DESC) AS RANKS
  FROM 
    adidas
  GROUP BY 
    `SALES METHOD`, Product
)
SELECT 
  `SALES METHOD`, 
  Product, 
  ORDER_NUM ,
  AVG_PROFIT ,
  PROFIT ,
  REVENUE
FROM 
  Ranked_Products
WHERE 
  RANKS <= 3
  ORDER BY REVENUE DESC ;


-- SELLING BY STATE 
WITH TOTAL_ORDER_COUNT AS (
  SELECT COUNT(*) AS ORDER_COUNTS
  FROM adidas
),
 TOTAL_REVENUE AS (
 SELECT SUM(`TOTAL SALES`) AS SALES
  FROM adidas
)
SELECT 
  State, 
  COUNT(*) AS NUM_ORDERS,
  ROUND(COUNT(*) / (SELECT ORDER_COUNTS FROM TOTAL_ORDER_COUNT) ,2)*100 AS PERCENT,
  ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
  SUM(`TOTAL SALES`) AS REVENUE,
  SUM(`Operating Profit`) AS PROFIT ,
  ROUND(SUM(`TOTAL SALES`) / (SELECT SALES FROM TOTAL_REVENUE) , 2)*100 AS REV_PERCENT
FROM 
  adidas
GROUP BY 
  State
ORDER BY 
  REVENUE DESC;
  
  -- SELLING TREND BY MONTH
SELECT 
  MONTH(`Invoice Date`) AS MONTH, 
  COUNT(*) AS NUM_ORDERS,
  SUM(`Operating Profit`) AS PROFIT ,
  ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
  SUM(`TOTAL SALES`) AS REVENUE
FROM 
  adidas
GROUP BY 
  MONTH
ORDER BY 
  REVENUE DESC;
  
    -- SELLING TREND BY YEAR
  SELECT 
  YEAR(`Invoice Date`) AS YEAR, 
  COUNT(*) AS NUM_ORDERS,
  SUM(`Operating Profit`) AS PROFIT ,
  ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
  SUM(`TOTAL SALES`) AS REVENUE
FROM 
  adidas
GROUP BY 
  YEAR
ORDER BY 
  REVENUE DESC;


-- SELLING BY REGION 
WITH TOTAL_ORDER_COUNT AS (
  SELECT COUNT(*) AS ORDER_COUNTS
  FROM adidas
),
 TOTAL_REVENUE AS (
 SELECT SUM(`TOTAL SALES`) AS SALES
  FROM adidas
)
SELECT 
  Region, 
  COUNT(*) AS NUM_ORDERS,
  ROUND(COUNT(*) / (SELECT ORDER_COUNTS FROM TOTAL_ORDER_COUNT) ,2)*100 AS ORD_NUM_PERCENT,
  ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
  SUM(`TOTAL SALES`) AS REVENUE,
  SUM(`Operating Profit`) AS PROFIT ,
  ROUND(SUM(`TOTAL SALES`) / (SELECT SALES FROM TOTAL_REVENUE) , 2)*100 AS REV_PERCENT
FROM 
  adidas
GROUP BY 
  Region
ORDER BY 
  REVENUE DESC;
  
  
  -- Top 3 BEST STATE BY REGION
-- Create CTE for best products 

WITH Ranked_region AS (
  SELECT 
    Region,
    State,
    COUNT(*) AS ORDER_NUM,
    SUM(`TOTAL SALES`) AS REVENUE,
    ROUND(AVG(`Operating Margin`), 2) AS AVG_PROFIT,
    SUM(`Operating Profit`) AS PROFIT,
    DENSE_RANK() OVER (PARTITION BY Region ORDER BY SUM(`TOTAL SALES`) DESC) AS RANKS
  FROM 
    adidas
  GROUP BY 
    Region, State
)
SELECT 
  Region, 
  State, 
  ORDER_NUM, 
  AVG_PROFIT, 
  PROFIT, 
  REVENUE
FROM 
  Ranked_region
WHERE 
  RANKS <= 3
ORDER BY 
  REVENUE DESC;
