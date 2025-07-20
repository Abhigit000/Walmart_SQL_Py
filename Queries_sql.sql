Show databases;
use walmart_db;
show tables;
select * from walmart
limit 10;




select count(distinct Branch) from walmart;

-- BUSINESS PROBLEMS
-- Q1: FIND DIFFERENT PAYMENT METHOD & NUMBER OF TRANSACTION,NUMBER OF QTY SOLD
 
 
 SELECT 
payment_method,
count(*) as num_of_payments,
SUM(quantity) AS num_qty_sold
FROM walmart
group by payment_method
order by num_of_payments DESC;

-- Q2: IDENTIFY THE HIGHEST RATED CATEGORY IN EACH BRANCH,DISPLAYING THE BRANCH,CATEGORY AVG RATING

SELECT *
FROM (
SELECT branch,
		category,
        AVG(rating)  AS avg_rating,
        RANK() OVER(PARTITION BY branch order by AVG(rating) DESC) AS ranking
FROM walmart
group by branch,category
) t
WHERE ranking = 1;



-- Q3: IDENTIFY THE BUSIEST DAY FOR EACH BRANCH BASED ON THE NUMBER OF TRANSACTIONS

SELECT branch, day_name, no_transactions,ranking
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranking = 1;

-- Q4: Calculate the total quantity of items sold per payment method

SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method
order by no_qty_sold DESC;



-- Q5: Determine the average, minimum, and maximum rating of categories for each city

SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;


-- Q6: Calculate the total profit for each category

SELECT 
    category,
 SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;



-- Q7: Determine the most common payment method for each branch

WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method,ranking
FROM cte
WHERE ranking = 1;



-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY num_invoices DESC;






-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total_amount) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total_amount) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

