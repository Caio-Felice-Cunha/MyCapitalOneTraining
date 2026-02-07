CREATE DATABASE IF NOT EXISTS Scenario01;
-- This is the crucial missing piece:
GRANT ALL PRIVILEGES ON Scenario01.* TO 'analyst'@'%';
FLUSH PRIVILEGES;

USE Scenario01;

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