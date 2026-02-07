USE Scenario01;

###################### SQL QUESTIONS ######################

# Fundamentals

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

## 3 - Compute total revenue (sum of payments) by product_name.