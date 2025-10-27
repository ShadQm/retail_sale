Create Table retail_sales (
	transactions_id	INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id	INT,
	gender	VARCHAR(10),
	age	INT,
	category VARCHAR(20),	
	quantity INT,
	price_per_unit FLOAT,	
	cogs FLOAT,	
	total_sale INT
);
SELECT * FROM retail_sales limit 10
SELECT COUNT(*) from retail_sales
-- DATA CLEANING
SELECT * FROM retail_sales
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

DELETE FROM retail_sales WHERE
	quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
   
-- DATA EXPLORATION
--Total sales
SELECT Count(*) as total_sales from retail_sales

-- Total Cutomers
SELECT Count(DISTINCT customer_id) as total_customers from retail_sales

-- Total categories
SELECT DISTINCT category as total_categories from retail_sales

-- DATA ANALYSIS/BUSINESS KEY PROBLEMS
-- All columns for sales made on '2022-11-05':
SELECT * FROM retail_sales WHERE
(sale_date = '2022-11-05');

-- All transactions where the category is 'Clothing' and the quantity sold is equal to 4 in the month of Nov-2022:
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND EXTRACT(YEAR FROM sale_date) = 2022
  AND EXTRACT(MONTH FROM sale_date) = 11
  AND quantity >= 4

-- The total sales (total_sale) for each category.:
SELECT category,SUM(total_sale) as total_sales_per_category,
COUNT(*) as total_orders
FROM retail_sales
GROUP BY category

-- The average age of customers who purchased items from the 'Beauty' category:
SELECT 
  'Beauty' AS category,
  FLOOR(AVG(age)) AS average_age
FROM retail_sales
WHERE category = 'Beauty';

-- All transactions where the total_sale is greater than 1000:
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- The total number of transactions (transaction_id) made by each gender in each category:
SELECT gender, category,count(transactions_id) FROM retail_sales
GROUP BY gender, category;

-- The average sale for each month and best selling month in each year:
SELECT DISTINCT ON (sale_year)
sale_year, sale_month, average_sale
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) as sale_year,
		EXTRACT(MONTH FROM sale_date) as sale_month,
		ROUND(AVG(total_sale)) as average_sale
	FROM retail_sales 
	GROUP BY  sale_month,  sale_year
)sub
ORDER BY sale_year, average_sale DESC

-- The top 5 customers based on the highest total sales:
--SELECT * FROM retail_sales limit 10
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- The number of unique customers who purchased items from each category:
SELECT category, COUNT(DISTINCT (customer_id)) as unique_customers
FROM retail_sales 
GROUP BY category

-- Create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift