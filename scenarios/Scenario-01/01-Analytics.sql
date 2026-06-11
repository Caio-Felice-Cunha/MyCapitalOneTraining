USE Scenario01;

##################################################################
###################### SQL QUESTIONS ############################
##################################################################

##################################################################
# Fundamentals
##################################################################

## 1 - List all active subscriptions with customer country and product name.
SELECT 
	subscriptions.subscription_id
    , customers.customer_id
    , customers.country
    , products.product_name
    , subscriptions.start_date
FROM
	subscriptions
    LEFT JOIN
		customers
        ON subscriptions.customer_id = customers.customer_id
        LEFT JOIN 
			products
			ON subscriptions.product_id = products.product_id
WHERE
	subscriptions.status = 'active'
ORDER BY
	subscriptions.subscription_id ASC;
    

## 2 - Count how many customers per country.
USE Scenario01;
SELECT
	COUNT(customer_id) AS Total_Customers
    , country
FROM 
	customers
GROUP BY
	country
;
    

## 3 - Compute total revenue (sum of payments) by product_name.
SELECT
	SUM(payments.amount) AS Revenue
    , products.product_name AS Product
FROM
	payments
    LEFT JOIN 
		subscriptions
        ON payments.subscription_id = subscriptions.subscription_id
        LEFT JOIN
			products
            ON subscriptions.product_id = products.product_id
GROUP BY
	products.product_name
ORDER BY
	Revenue DESC
;

##################################################################
# Intermediate Business Questions
##################################################################

## 4 - For each country, what is the total revenue and number of unique customers who paid?

SELECT
	customers.country AS Country
    , SUM(payments.amount) AS Payments
    , COUNT(DISTINCT customers.customer_id) AS Customers
FROM
	customers
    JOIN
		subscriptions
        ON customers.customer_id = subscriptions.customer_id
        JOIN
			payments
            ON subscriptions.subscription_id = payments.subscription_id
GROUP BY
	customers.country
;

## 5 - For each segment (SMB, ENT, IND), what is the average monthly revenue per paying customer?
### Option 01 - Includes the Date at the end
/*
In this outer query, I'm still grouping by Payment_Month. 
Because the CTE already grouped the data into one row per month, this Option 01 final AVG() function is only averaging one single row at a time.

Essentially, this query is just showing the "Revenue per Customer" for each specific month, rather than the average across all months for that segment.
*/

WITH monthly_totals AS(
SELECT
	customers.segment
    , DATE_FORMAT(payments.payment_date, "%Y-%m-01") AS Payment_Month
    , SUM(payments.amount) AS Monthly_Revenue
    , COUNT(DISTINCT customers.customer_id) as Paying_Customers
FROM
	customers
    JOIN 
		subscriptions
        ON customers.customer_id = subscriptions.customer_id
        JOIN
			payments
			ON subscriptions.subscription_id = payments.subscription_id
GROUP BY
	customers.segment
    , Payment_month
)
SELECT
	segment
    , Payment_Month
    , ROUND(AVG(Monthly_Revenue/Paying_Customers),2) AS AVG_REV_MONT_PER_CUST
FROM 
	monthly_totals
GROUP BY
	segment
    , Payment_Month
;


### Option 02 - Only Segment and AVG_REV
-- This is more aligned with the question
WITH monthly_totals AS(
SELECT
	customers.segment
    , DATE_FORMAT(payments.payment_date, "%Y-%m-01") AS Payment_Month
    , SUM(payments.amount) AS Monthly_Revenue
    , COUNT(DISTINCT customers.customer_id) as Paying_Customers
FROM
	customers
    JOIN 
		subscriptions
        ON customers.customer_id = subscriptions.customer_id
        JOIN
			payments
			ON subscriptions.subscription_id = payments.subscription_id
GROUP BY
	customers.segment
    , Payment_month
)
SELECT
	segment
    , ROUND(AVG(Monthly_Revenue/Paying_Customers),2) AS AVG_REV_MONT_PER_CUST
FROM 
	monthly_totals
GROUP BY
	segment
;


## 6 - Identify customers who upgraded from Basic Analytics to Pro Analytics at any time.
/*
- The customer must have had Basic Analytics before
- Then later had Pro Analytics
- Order in time matters*/

WITH customer_history AS (
	SELECT
		subscriptions.customer_id
		, products.product_name
		, subscriptions.start_date
		, MAX(CASE
			WHEN products.product_name = 'Basic Analytics' THEN 1 
			ELSE 0
		END) 
			OVER (
				PARTITION BY subscriptions.customer_id 
				ORDER BY subscriptions.start_date
				ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
				) AS Had_Basic_Previously
	FROM subscriptions
		JOIN products ON subscriptions.product_id = products.product_id
)
SELECT
	DISTINCT customer_id
FROM customer_history
WHERE
	product_name = 'Pro Analytics'
    AND Had_Basic_Previously = 1
;

##################################################################
# Time-based & retention style logic
# Assume we care about the period 2024-03-01 to 2024-04-30.
##################################################################

## 7 - For each product, compute total revenue in that period.
SELECT
	products.product_name AS Product
    , SUM(payments.amount) AS Revenue_Mar_Apr
FROM
	payments
    JOIN
		subscriptions
        ON payments.subscription_id = subscriptions.subscription_id
        JOIN
			products
            ON subscriptions.product_id = products.product_id
WHERE
	payments.payment_date BETWEEN '2024-03-01' AND '2024-04-30'
GROUP BY
	products.product_name
ORDER BY
	Revenue_Mar_Apr DESC
;


## 8 - For each customer, determine their first payment date and latest payment date.
SELECT
	customers.customer_id AS Customer
    , MIN(payments.payment_date) AS First_Payment_Date
    , MAX(payments.payment_date) AS Last_Payment_Date
FROM
	customers
    JOIN
		subscriptions
        ON customers.customer_id = subscriptions.customer_id
        JOIN
			payments
            ON subscriptions.subscription_id = payments.subscription_id
GROUP BY
	customers.customer_id
ORDER BY
	customers.customer_id ASC
;


## 9 - Find the month-over-month revenue trend (by calendar month) for the whole business.
SELECT
	DATE_FORMAT(payments.payment_date, "%Y-%m-01") AS Payment_Month
    , SUM(payments.amount) AS Monthly_Revenue
FROM
	payments
GROUP BY
	Payment_Month
ORDER BY
	Payment_Month ASC
;

##################################################################
# Window functions (Capital One-style)
##################################################################

## 10 - For each country, rank customers by total revenue and return the top 3 per country.
WITH revenue_per_customer AS (
	SELECT
		customers.customer_id
        , customers.country
        , SUM(payments.amount) AS Total_Revenue
	FROM
		customers
        JOIN
			subscriptions
            ON customers.customer_id = subscriptions.customer_id
            JOIN
				payments
                ON subscriptions.subscription_id = payments.subscription_id
	GROUP BY
		customers.customer_id
        , customers.country
)
, ranked AS (
	SELECT
		customer_id
        , country
        , Total_Revenue
        , DENSE_RANK() OVER (
			PARTITION BY country
            ORDER BY Total_Revenue DESC
		) AS Revenue_Rank
	FROM
		revenue_per_customer
)
SELECT
	country
    , customer_id
    , Total_Revenue
    , Revenue_Rank
FROM
	ranked
WHERE
	Revenue_Rank <= 3
ORDER BY
	country ASC
    , Revenue_Rank ASC
    , Total_Revenue DESC
;


## 11 - For each subscription, compute the cumulative revenue over time (ordered by payment_date).
SELECT
	subscriptions.subscription_id
    , payments.payment_date
    , payments.amount
    , SUM(payments.amount) OVER (
		PARTITION BY subscriptions.subscription_id
        ORDER BY payments.payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS Cumulative_Revenue
FROM
	payments
    JOIN
		subscriptions
        ON payments.subscription_id = subscriptions.subscription_id
ORDER BY
	subscriptions.subscription_id ASC
    , payments.payment_date ASC
;


## 12 - For each product, compute the average payment amount and flag each payment above that average.
WITH with_avg AS (
	SELECT
		products.product_name
        , payments.payment_id
        , payments.amount
        , AVG(payments.amount) OVER (
			PARTITION BY products.product_id
		) AS Avg_Amount
	FROM
		payments
        JOIN
			subscriptions
            ON payments.subscription_id = subscriptions.subscription_id
            JOIN
				products
                ON subscriptions.product_id = products.product_id
)
SELECT
	product_name
    , payment_id
    , amount
    , ROUND(Avg_Amount, 2) AS Avg_Amount
    , CASE
		WHEN amount > Avg_Amount THEN 'above_avg'
        WHEN amount = Avg_Amount THEN 'equal_avg'
        ELSE 'below_avg'
	END AS Amount_vs_Avg
FROM
	with_avg
ORDER BY
	product_name ASC
    , payment_id ASC
;