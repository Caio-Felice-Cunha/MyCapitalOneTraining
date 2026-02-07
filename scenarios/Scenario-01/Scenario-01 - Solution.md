All table data is in four CSVs inside MyCapitalOneTraining\data\raw: **customers, products, subscriptions, payments**.

***

## 1. Business scenario

You’re a **Senior Data Analyst** at a SaaS company that sells analytics products to businesses across North and South America.

- Each **customer** can have multiple **subscriptions**.
- Each subscription is for a **product** (monthly SaaS).
- Each subscription generates **payments** over time.
- Management wants to understand:
  - Revenue by product and region.
  - Churn and retention patterns.
  - Upsell from Basic → Pro or Supply Chain / Fraud products.

You have four tables.

### customers

Columns:

- customer_id (PK)
- country (e.g., CA, US, BR)
- province_state (e.g., ON, BC, NY)
- signup_date (DATE)
- segment (SMB, ENT, IND)

### products

Columns:

- product_id (PK)
- product_name (Basic Analytics, Pro Analytics, Supply Chain Opt, Fraud Detector)
- category (Analytics, Supply Chain, Risk)
- monthly_price (numeric)

### subscriptions

Columns:

- subscription_id (PK)
- customer_id (FK → customers)
- product_id (FK → products)
- start_date (DATE)
- end_date (DATE, nullable if active)
- status (active / cancelled)

### payments

Columns:

- payment_id (PK)
- subscription_id (FK → subscriptions)
- payment_date (DATE)
- amount (numeric)

***

## 2. Setup in your SQL database

Create the tables (ANSI-style; adapt types to your engine):

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    country VARCHAR(2),
    province_state VARCHAR(10),
    signup_date DATE,
    segment VARCHAR(10)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    monthly_price DECIMAL(10,2)
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    subscription_id INT REFERENCES subscriptions(subscription_id),
    payment_date DATE,
    amount DECIMAL(10,2)
);
```

Then import the CSVs **customers.csv, products.csv, subscriptions.csv, payments.csv** into those tables.

***

## 3. Query set – from basic to advanced

Use these as timed drills (e.g., 10–12 minutes for harder ones). Many mirror the kind of questions you’d see in a CodeSignal/Capital One assessment. [linkjob](https://www.linkjob.ai/interview-questions/capital-one-data-analyst-codesignal-questions-preparation/)

### A. Fundamentals

1. List all **active subscriptions** with customer country and product name.

```sql
SELECT s.subscription_id,
       c.customer_id,
       c.country,
       p.product_name,
       s.start_date
FROM subscriptions s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
WHERE s.status = 'active';
```

2. Count **how many customers per country**.

```sql
SELECT country,
       COUNT(*) AS customer_count
FROM customers
GROUP BY country;
```

3. Compute **total revenue** (sum of payments) by **product_name**.

```sql
SELECT p.product_name,
       SUM(pay.amount) AS total_revenue
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.subscription_id
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;
```

### B. Intermediate business questions

4. For each **country**, what is the **total revenue** and **number of unique customers who paid**?

```sql
SELECT c.country,
       COUNT(DISTINCT c.customer_id) AS paying_customers,
       SUM(pay.amount) AS total_revenue
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.subscription_id
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.country;
```

5. For each **segment** (SMB, ENT, IND), what is the **average monthly revenue per paying customer**?

Hint: approximate monthly revenue by summing payments and dividing by count of distinct customers, grouped by segment.

```sql
WITH monthly_metrics AS (
    -- Step 1: Calculate total revenue and unique paying customers per month/segment
    SELECT 
        c.segment,
        DATE_FORMAT(p.payment_date, '%Y-%m-01') AS payment_month,
        SUM(p.amount) AS total_revenue,
        COUNT(DISTINCT c.customer_id) AS paying_customers
    FROM customers c
    JOIN subscriptions s ON c.customer_id = s.customer_id
    JOIN payments p ON s.subscription_id = p.subscription_id
    GROUP BY c.segment, payment_month
)
-- Step 2: Average the "Revenue per Customer" across all months
SELECT 
    segment,
    ROUND(AVG(total_revenue / paying_customers), 2) AS avg_monthly_rev_per_customer
FROM monthly_metrics
GROUP BY segment;
```

6. Identify customers who **upgraded** from **Basic Analytics** to **Pro Analytics** at any time.

```sql
SELECT DISTINCT c.customer_id
FROM customers c
JOIN subscriptions s1 ON c.customer_id = s1.customer_id
JOIN products p1 ON s1.product_id = p1.product_id
JOIN subscriptions s2 ON c.customer_id = s2.customer_id
JOIN products p2 ON s2.product_id = p2.product_id
WHERE p1.product_name = 'Basic Analytics'
  AND p2.product_name = 'Pro Analytics';
```

### C. Time-based & retention style logic

Assume we care about the period **2024-03-01 to 2024-04-30**.

7. For each product, compute **total revenue** in that period.

```sql
SELECT p.product_name,
       SUM(pay.amount) AS revenue_mar_apr
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.subscription_id
JOIN products p ON s.product_id = p.product_id
WHERE pay.payment_date BETWEEN DATE '2024-03-01' AND DATE '2024-04-30'
GROUP BY p.product_name
ORDER BY revenue_mar_apr DESC;
```

8. For each **customer**, determine their **first payment date** and **latest payment date**.

```sql
SELECT c.customer_id,
       MIN(pay.payment_date) AS first_payment_date,
       MAX(pay.payment_date) AS last_payment_date
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN payments pay ON s.subscription_id = pay.subscription_id
GROUP BY c.customer_id;
```

9. Find the **month-over-month revenue** trend (by calendar month) for the entire business.

PostgreSQL-style:

```sql
SELECT DATE_TRUNC('month', pay.payment_date) AS month,
       SUM(pay.amount) AS monthly_revenue
FROM payments pay
GROUP BY DATE_TRUNC('month', pay.payment_date)
ORDER BY month;
```

MySQL-style alternative:

```sql
SELECT DATE_FORMAT(pay.payment_date, '%Y-%m-01') AS month,
       SUM(pay.amount) AS monthly_revenue
FROM payments pay
GROUP BY DATE_FORMAT(pay.payment_date, '%Y-%m-01')
ORDER BY month;
```

### D. Window functions (Capital One‑style) [interviewquery](https://www.interviewquery.com/interview-guides/capital-one-data-analyst)

10. For each **country**, rank customers by **total revenue** and return the **top 3 per country**.

```sql
WITH revenue_per_customer AS (
    SELECT c.customer_id,
           c.country,
           SUM(pay.amount) AS total_revenue
    FROM customers c
    JOIN subscriptions s ON c.customer_id = s.customer_id
    JOIN payments pay ON s.subscription_id = pay.subscription_id
    GROUP BY c.customer_id, c.country
),
ranked AS (
    SELECT customer_id,
           country,
           total_revenue,
           DENSE_RANK() OVER (
               PARTITION BY country
               ORDER BY total_revenue DESC
           ) AS revenue_rank
    FROM revenue_per_customer
)
SELECT *
FROM ranked
WHERE revenue_rank <= 3
ORDER BY country, revenue_rank, total_revenue DESC;
```

11. For each **subscription**, compute the **cumulative revenue over time** (ordered by payment_date).

```sql
SELECT s.subscription_id,
       pay.payment_date,
       pay.amount,
       SUM(pay.amount) OVER (
           PARTITION BY s.subscription_id
           ORDER BY pay.payment_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_revenue
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.subscription_id
ORDER BY s.subscription_id, pay.payment_date;
```

12. For each **product**, calculate the **average payment amount** and then show each payment with a flag if it’s **above average** for that product.

```sql
WITH product_payments AS (
    SELECT p.product_id,
           p.product_name,
           pay.payment_id,
           pay.amount
    FROM payments pay
    JOIN subscriptions s ON pay.subscription_id = s.subscription_id
    JOIN products p ON s.product_id = p.product_id
),
with_avg AS (
    SELECT product_id,
           product_name,
           payment_id,
           amount,
           AVG(amount) OVER (PARTITION BY product_id) AS avg_amount
    FROM product_payments
)
SELECT product_name,
       payment_id,
       amount,
       avg_amount,
       CASE WHEN amount > avg_amount THEN 'above_avg'
            WHEN amount = avg_amount THEN 'equal_avg'
            ELSE 'below_avg'
       END AS amount_vs_avg
FROM with_avg
ORDER BY product_name, payment_id;
```

***

## 4. How to train “like the assessment”

Use this environment as a **mock CodeSignal**:

- Timebox:
  - Easy: 5–7 minutes.
  - Medium: 10–12 minutes.
  - Hard (window + multiple joins): 15 minutes max.
- After you solve:
  - Refactor to use **CTEs** and **window functions** where appropriate (they love these). [discover.codesignal](https://discover.codesignal.com/rs/659-AFH-023/images/Data-Analytics-Skills-Evaluation-Framework-CodeSignal-Skills-Evaluation-Lab-Short.pdf)
  - Check if there’s a **simpler** version of the query that you could type faster.

If you’d like, next step I can:

- Add **3–5 new questions** specifically framed as Capital One “business questions” (e.g., “Which segment should we prioritize for upsell and why?”) that you answer with both SQL and a brief written insight, just like in a CodeSignal analytics assessment.