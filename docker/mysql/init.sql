CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    category VARCHAR(50),
    amount DECIMAL(10,2),
    transaction_date DATE
);

INSERT INTO transactions (customer_id, category, amount, transaction_date)
VALUES
(1, 'Food', 120.50, '2023-01-01'),
(1, 'Travel', 300.00, '2023-01-02'),
(2, 'Food', 75.20, '2023-01-01'),
(2, 'Bills', 220.00, '2023-01-03');
