# Capital One CodeSignal Prep: Senior Associate, Data Analyst

This repository serves as a dedicated environment for mastering the technical competencies required for Capital One's Data Analyst assessment. The goal is to simulate production-grade data workflows using **SQL (MySQL)**, **Python (Pandas/Jupyter)**, **Excel** and **Docker**.

<img width="1024" height="1024" alt="Feb 6, 2026, 07_39_58 PM" src="https://github.com/user-attachments/assets/4455d218-60bf-4d99-a3fa-2f6b6b9abab6" />

## 🚀 Overview

Capital One’s Senior Associate Data Analyst role demands a blend of rigorous statistical analysis and scalable data engineering. This project mimics that ecosystem by containerizing a MySQL database and providing a sandbox for exploratory data analysis (EDA) and complex query optimization.

### Key Objectives

* **SQL Mastery:** Practice complex joins, Window Functions, and CTEs within a local MySQL instance.
* **Pythonic Analysis:** Clean and transform raw transaction data using NumPy and Pandas.
* **Reproducibility:** Use Docker to ensure the environment is consistent across any machine.

---

## 🏗 Project Architecture

```text
capitalone-codesignal/
├── docker/
│   └── mysql/
│       └── init.sql           # Database schema and seed data
├── notebooks/
│   └── 01_exploratory_analysis.ipynb  # EDA and Python-based logic
├── data/
│   ├── raw/                   # Input files (e.g., transactions.xlsx)
│   └── output/                # Processed results
├── sql/
│   └── analytics.sql          # Production-ready SQL queries
├── Dockerfile                 # Python environment config
├── docker-compose.yml         # Multi-container orchestration
├── requirements.txt           # Python dependencies
└── README.md                  # You are here

```

---

## 🛠 Setup & Installation

### 1. Prerequisites

Ensure you have [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) installed.

### 2. Spin Up the Environment

This command launches the MySQL 8.0 database and initializes it with the schema found in `docker/mysql/init.sql`.

```bash
docker-compose up -d

```

### 3. Install Python Dependencies

If you are running the notebooks locally (outside of Docker):

```bash
pip install -r requirements.txt

```

---

## 📊 Workflow

### SQL Analysis

The `sql/analytics.sql` file contains solutions to high-level business questions

### Python Exploratory Data Analysis

The Jupyter Notebooks in `/notebooks` focus on:

* Handling missing values;
* Visualizing distribution patterns;
* Validating data types before ingestion into the MySQL instance.

---

## 🧠 Study Focus Areas (Capital One Specific)

Based on the Senior Associate Data Analyst profile, this repo prioritizes:

1. **Case Study Logic:** Not just *how* to code, but *why*. (e.g., "What does this spike in transaction volume mean for liquidity?")
2. **Data Quality:** Identifying outliers and "dirty" data in the `raw/` directory.
3. **Performance:** Writing SQL queries that don't crawl when the dataset hits millions of rows.

---

> **Note:** This repository is for educational purposes and personal study. All datasets used are synthetic or open-source.

---

# My study plan (One-week prep tailored plan)

## **Day 1 – Platform + format**

- Create the architecture for the project, and start stablishing a more organized way to create database, business questions and related subjects.

## **Day 2–3 – SQL reps (targeted)**

- Use AI to create problems and data for my databases:
  - 5–8 SQL problems per day focusing on joins + window functions + CTEs similar to the real scenarios. 
- Solving the problems.
- My goal: each medium-level business query in **≤10 minutes**.

## **Day 4-5 – Python**

- Use AI to create problems and data for my analytics:
  - 5–8 Python problems per day focusing on data analytics. 
- Solving the problems.
- My goal: each medium-level business query in **≤10 minutes**.

## **Day 6 – CSV data mini‑case**

- Grab any Kaggle dataset (transactions, customers, churn).
- Timebox 60–70 min:
  - Load in pandas or a local SQL DB.
  - Answer 8–10 questions written by AI in “CodeSignal style” (proportions, group comparisons, trends).
- Force myself to **move on** if stuck >5 min (simulate the real timing).

## **Day 7 – Mixed drill**

- 30–40 minutes:
  - 3–4 conceptual multiple-choice style questions you invent:
    - E.g., “If campaign A has 5% conversion on 10,000 users and B has 6% on 2,000 users, which is better and why?”
- 30–40 minutes:
  - 2 SQL questions, 1 with a window function, 1 with a tricky date filter.

## **Day 7 – Light review + rest**

- Review my most common mistakes and patterns:
  - Wrong join types, forgetting GROUP BY columns, off-by-one in window ranking, etc.
- Sleep well; treat the test day like race day.