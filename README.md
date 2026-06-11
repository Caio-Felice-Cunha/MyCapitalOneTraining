# Capital One CodeSignal Prep: Senior Associate, Data Analyst

A self-study sandbox for the Capital One Data Analyst (CodeSignal) assessment. It ships a small synthetic SaaS dataset (customers, products, subscriptions, payments) in two interchangeable forms, a MySQL seed and matching CSVs, plus a set of timed SQL drills with reference solutions and a pandas EDA notebook.

**What it is:** practice material, not a product. The business problem it models is the kind a SaaS data analyst answers daily: revenue by product and region, churn and retention, and upsell detection.

**Run it in ~2 minutes:** `docker-compose up -d` brings up MySQL (seeded) and JupyterLab. No Docker? `pip install -r requirements.txt` then open `notebooks/01_exploratory_analysis.ipynb`; it reads the CSVs and needs no database. The drills live in `scenarios/Scenario-01/`.

This repository simulates the workflow using **SQL (MySQL)**, **Python (Pandas/Jupyter)**, **Excel** and **Docker**.

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
MyCapitalOneTraining/
├── docker/
│   └── mysql/
│       └── init.sql                       # Schema + seed data (source of truth)
├── scenarios/
│   └── Scenario-01/
│       ├── Scenario-01.md                 # The 12-question drill brief
│       ├── Scenario-01 - Solution.md      # Reference solutions for all 12
│       └── 01-Analytics.sql               # Worked solutions (this is the showcase)
├── notebooks/
│   └── 01_exploratory_analysis.ipynb      # pandas EDA, runs on the CSVs alone
├── data/
│   └── raw/                               # customers/products/subscriptions/payments CSVs
│       └── transactions.csv               # small extra table (semicolon-delimited)
├── scripts/
│   └── export_csvs.py                     # regenerate the CSVs from init.sql
├── tests/
│   └── test_data_integrity.py             # pytest data-integrity checks
├── Dockerfile                             # Python environment for JupyterLab
├── docker-compose.yml                     # MySQL + JupyterLab orchestration
├── .env.example                           # local sandbox credentials (copy to .env)
├── requirements.txt                       # runtime dependencies
├── requirements-dev.txt                   # test/dev dependencies
└── README.md                              # You are here

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

JupyterLab is then available at `http://localhost:8888` (token `capitalone`, configurable in `.env`). The credentials in `docker-compose.yml` and `.env.example` are local-sandbox-only defaults over synthetic data. Do not reuse them anywhere real.

### 3. Install Python Dependencies

If you are running the notebook locally (outside of Docker):

```bash
pip install -r requirements.txt
# for the tests as well:
pip install -r requirements-dev.txt
```

---

## 📊 Workflow

### SQL drills

`scenarios/Scenario-01/01-Analytics.sql` holds worked solutions to all 12 business questions, from fundamentals (joins, group by) through window functions (`DENSE_RANK`, cumulative sums, partitioned averages) and an upgrade-detection query using `ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING`. The brief is in `Scenario-01.md` and reference answers are in `Scenario-01 - Solution.md`.

### Python Exploratory Data Analysis

`notebooks/01_exploratory_analysis.ipynb` reads the CSVs in `data/raw/`, checks data quality (orphan foreign keys, null `end_date` only on active subscriptions), aggregates revenue by product and by country, and writes `data/output/results.xlsx`. It runs with pandas alone; an optional final cell runs the same revenue query against MySQL when the DB env vars are present.

### Data sources stay in sync

`docker/mysql/init.sql` is the single source of truth. The four CSVs in `data/raw/` are generated from it by `scripts/export_csvs.py`, so the CSV-only workflow and the MySQL workflow return the same answers. `tests/test_data_integrity.py` enforces that. After editing `init.sql`, regenerate with:

```bash
python scripts/export_csvs.py
pytest -q
```

---

## ✅ Results

These come from running the notebook against the committed data (30 customers, 12 products, 60 subscriptions, 90 payments). They are reproducible, not stored estimates: run the notebook or `pytest -q` to regenerate them.

**Top products by total revenue (sum of payments):**

| Product | Total revenue |
|---|---|
| Supply Chain Opt | 4,614 |
| Fraud Detector | 4,389 |
| Basic Analytics | 1,972 |
| Pro Analytics | 1,855 |
| Enterprise Analytics | 1,797 |

**Revenue and paying customers by country:**

| Country | Total revenue | Paying customers |
|---|---|---|
| CA | 8,993 | 5 |
| US | 6,252 | 3 |
| BR | 3,255 | 2 |

Total payments across the dataset sum to 18,500. Of the 30 customers, 10 have subscriptions and payments (the rest are signups with no purchase yet), which is realistic for a retention/upsell drill.

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