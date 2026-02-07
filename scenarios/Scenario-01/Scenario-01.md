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

Use these as timed drills (e.g., 10–12 minutes for harder ones). Many mirror the kind of questions you’d see in a CodeSignal/Capital One assessment. 

### A. Fundamentals

1. List all **active subscriptions** with customer country and product name.

2. Count **how many customers per country**.

3. Compute **total revenue** (sum of payments) by **product_name**.

### B. Intermediate business questions

4. For each **country**, what is the **total revenue** and **number of unique customers who paid**?

5. For each **segment** (SMB, ENT, IND), what is the **average monthly revenue per paying customer**?

Hint: approximate monthly revenue by summing payments and dividing by count of distinct customers, grouped by segment.

6. Identify customers who **upgraded** from **Basic Analytics** to **Pro Analytics** at any time.

### C. Time-based & retention style logic

Assume we care about the period **2024-03-01 to 2024-04-30**.

7. For each product, compute **total revenue** in that period.

8. For each **customer**, determine their **first payment date** and **latest payment date**.

9. Find the **month-over-month revenue** trend (by calendar month) for the entire business.

### D. Window functions (Capital One‑style) [interviewquery](https://www.interviewquery.com/interview-guides/capital-one-data-analyst)

10. For each **country**, rank customers by **total revenue** and return the **top 3 per country**.

11. For each **subscription**, compute the **cumulative revenue over time** (ordered by payment_date).

12. For each **product**, calculate the **average payment amount** and then show each payment with a flag if it’s **above average** for that product.

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
