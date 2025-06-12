**Table of Contents**

1. [Project Name](#project-name)
2. [Project Background](#project-background)
3. [Project Goals](#project-goals)
4. [Data Structure & Initial Checks](#data-structure--initial-checks)
5. [Executive Summary](#executive-summary)
6. [Insights Deep Dive](#Insights-Deep-Dive)
   - [Category 1: Sales Performance by Region](#category-1-sales-performance-by-region)
   - [Category 2: Product Performance Analysis](#category-2-product-performance-analysis)
   - [Category 3: Sales Channel Insights](#category-3-sales-channel-insights)
   - [Category 4: Profitability Analysis](#category-4-profitability-analysis)
7. [Recommendations](#recommendations)
8. [Technical Details](#technical-details)
9. [Assumptions and Caveats](#assumptions-and-caveats)

---

**Project Name:** Adidas Sales Performance Analysis

---

**Project Background**
Adidas operates as a global sportswear company, selling athletic and casual footwear, apparel, and accessories. This analysis focuses on Adidas' retail sales data from January 2020 to December 2020, covering multiple retailers across various regions in the United States. The dataset consists of 9,648 sales transactions across different product categories, including street footwear, athletic footwear, and apparel. The objective is to analyze sales trends, identify high-performing regions, and assess profitability across different products and sales channels.

---

**Project Goals**
As a data analyst at Adidas, this project aims to:

- Identify regional sales performance trends to optimize inventory allocation.
- Analyze product sales to determine best-selling and underperforming items.
- Compare in-store vs. online sales to assess channel efficiency.
- Evaluate profitability by product type and retailer to enhance pricing strategies.

---

**Data Structure & Initial Checks**
The dataset contains four key tables with 9,648 records. Below is a description of the main columns:

- **Retailer & Retailer ID:** Identifies different retailers.
- **Invoice Date:** Provides a time reference for each sale.
- **Region, State, City:** Indicates the geographic location of each sale.
- **Product:** Specifies the product category.
- **Price per Unit, Units Sold, Total Sales:** Details on sales revenue and volume.
- **Operating Profit & Operating Margin:** Measures profitability.
- **Sales Method:** Indicates whether the sale was online or in-store.
![Screenshot_16-2-2025_20423_dbdiagram io](https://github.com/user-attachments/assets/8df3f419-9354-47a9-9801-edfd5f0bd0c6)

---

**Executive Summary**
The analysis reveals key insights into Adidas' sales performance:

1. The **West region** generated the highest revenue, accounting for 30% of total sales, followed by the Northeast region with 21%.
2. **Men’s Athletic Footwear** was the best-selling product, contributing 30% of total units sold.
3. **In-store sales** accounted for 40% of total revenue, highlighting the importance of physical retail channels.
4. Profitability varied significantly by product category, with **Men Street Footwear achieving the highest operating margin (45%)**.

---

**Insights Deep Dive**

**Category 1: Sales Performance by Region**

- The West led in sales, contributing Nearly $270 million in revenue.
- The Midwest showed lower sales performance despite high population density.
- The West region exhibited a strong performance in in-store sales, with California emerging as a key contributor, accounting for 7% of the company's total sales. Notably, July saw the highest concentration of sales within the state, indicating a potential seasonal demand surge during this period.

**Category 2: Product Performance Analysis**

- Men’s Athletic Footwear had the highest sales volume (593 K units).
- Women’s Street Footwear had a lower sales volume but third higher average margin.
- Apparel products exhibited seasonal demand spikes. 

**Category 3: Sales Channel Insights**

- In-store sales were dominant, accounting for 40% of total revenue.
- Online sales showed a steady increase throughout the year, peaking in Q3.
- Retailers with strong digital platforms had higher customer retention rates.

**Category 4: Profitability Analysis**

- Men Street Footwear products had the highest Average profit margins (45%) compared to men athlete footwear (40%).
- Discounts on Men’s Street Footwear impacted profit margins in Q3.
- The highest profit-generating region was the West.

---
![Screenshot_16-2-2025_195421_chatgpt com](https://github.com/user-attachments/assets/fc8354fd-ae0d-457d-90eb-c361e689f6a2)

**Recommendations**

1. **Increase inventory allocation** to the West region to maximize revenue potential. The sales performance in this region indicates a strong customer demand, especially in California. Expanding distribution channels and optimizing supply chain logistics can help meet customer demand more efficiently and reduce stockouts.

2. **Expand digital marketing efforts** in the South to drive online sales. Despite steady online sales growth, targeted advertising and promotions in underperforming regions could improve customer acquisition and engagement, particularly for high-margin products like Men’s Street Footwear.

3. **Re-evaluate pricing strategy** for Women’s Street Footwear to improve sales volume. Although this category has strong margins, its sales volume remains below optimal levels. Implementing strategic discounts, bundle deals, or loyalty rewards could increase sales while maintaining profitability.

4. **Strengthen in-store promotions** to maintain customer engagement. With 40% of total revenue coming from physical stores, Adidas should consider enhancing in-store experiences, offering limited-time discounts, and leveraging seasonal trends to boost foot traffic and conversions.

5. **Monitor seasonal demand** for apparel and adjust inventory accordingly. The data indicates periodic sales spikes in apparel, suggesting the need for a dynamic inventory management approach. Analyzing historical data further can help predict future trends and optimize stock levels for peak seasons.

6. **Leverage predictive analytics** to anticipate demand fluctuations. By integrating machine learning models, Adidas can forecast sales patterns with higher accuracy and align production schedules with expected market demand, reducing excess inventory costs.

7. **Enhance retailer partnerships** by providing data-driven insights on sales trends and customer preferences. Retailers with robust digital platforms showed higher retention rates, suggesting that sharing analytical insights with retail partners could improve their sales performance and Adidas' overall revenue.

8. **Optimize discounting strategies** to prevent margin erosion. The Q3 discounting on Men’s Street Footwear impacted overall profit margins. A more targeted approach, such as personalized discounts based on customer purchase history, can drive sales without significantly affecting profitability.

---

**Technical Details**

- **SQL:** Used for data extraction, cleaning, and analysis.
- **Figma & Power BI:** Used Figma for dashboard design planning and Power BI for interactive sales trend visualization.
- **Excel:** Conducted additional exploratory data analysis.

---

**Assumptions and Caveats**

1. Sales data is assumed to be complete, but missing values may impact analysis accuracy.
2. Operating margin calculations assume a standard cost model across all retailers.
3. Seasonality effects may not fully reflect external market trends.

---
