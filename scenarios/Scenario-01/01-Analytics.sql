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
	COUNT(customer_id) AS Total_Custumers
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