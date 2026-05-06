# Fraud Data Analytics: Unauthorized Account Usage Detection

## Project Description

This project applies a scenario-driven fraud analytics methodology to identify patterns associated with unauthorized use of customer financial accounts.

The analysis focuses on detecting behavioural and transactional anomalies linked to:
- account takeover activity
- rapid transaction execution
- transaction fragmentation
- dormant account reactivation

The project combines fraud risk assessment methodology with SQL-based data interrogation techniques to identify potentially suspicious account behaviour.

---

# Project Objectives

- Detect patterns consistent with unauthorized account usage
- Identify high-risk transactional behaviour
- Apply scenario-driven fraud analytics methodology
- Develop reusable SQL-based fraud detection logic
- Demonstrate data-driven fraud investigation techniques

---

# Dataset

The project uses a simulated banking transaction dataset from Kaggle.

- Dataset source:  
https://www.kaggle.com/datasets/sgpjesus/bank-account-fraud-dataset-neurips-2022

- Data includes:
  - transaction activity
  - account identifiers
  - transaction timestamps
  - device and merchant information
  - login attempts
  - transaction amounts

---

# Fraud Scenario Framework

The project follows a scenario-driven fraud analytics approach.

## Inherent Fraud Scheme

Unauthorized control and use of customer financial accounts resulting in misappropriation of funds.

---

## Fraud Scenarios

### Scenario 1 — Account Takeover & Rapid Fund Extraction

Detection logic focused on identifying:
- unusually high transaction frequency
- abnormal daily transaction amounts
- fragmented transaction behaviour
- rapid transaction execution patterns

---

### Scenario 2 — Dormant Account Reactivation

Detection logic focused on identifying:
- long periods of account inactivity
- sudden transaction reactivation
- deviations from historical account behaviour

---

# Data Analytics Approach

The analysis included:
- data quality assessment
- transaction pattern analysis
- behavioural baseline creation
- anomaly identification
- cumulative fraud flag analysis

SQL interrogation techniques included:
- Common Table Expressions (CTEs)
- Window Functions (`LAG`, `AVG`)
- Behavioural baselines
- Temporal analysis
- Ratio analysis
- Risk flag generation

---

# Key Detection Indicators

The project identified several behavioural indicators associated with potentially suspicious activity:

- abnormal transaction frequency
- unusually high transaction values
- fragmented transaction patterns
- deviations from historical activity
- extended account dormancy followed by reactivation
- elevated login attempt counts

---

# Technologies Used

- SQL (MySQL)
- MySQL Workbench
- Fraud Analytics Methodology
- Behavioural Analysis
- Data Interrogation Techniques

---

# Project Structure

```text
fraud-data-analytics/
│
├── sql/
│   ├── scenario1_account_takeover.sql
│   ├── scenario2_dormant_accounts.sql
│   └── data_quality_checks.sql
│
├── report/
│   └── fraud_data_analytics_report.pdf
│
├── data/
│   └── bank_transactions.csv
│
└── README.md
```

---

# Key Outcomes

- Applied scenario-driven fraud analytics methodology
- Developed SQL-based fraud detection logic
- Built behavioural baselines for anomaly detection
- Identified suspicious transaction and dormancy patterns
- Demonstrated practical fraud investigation techniques using SQL

---

# Business Relevance

This project demonstrates how SQL-based fraud analytics can support:
- transaction monitoring
- fraud investigations
- behavioural anomaly detection
- account takeover detection
- risk-based alert generation
- financial crime analytics

The analytical approach reflects practical fraud detection workflows used in banking and financial crime environments.

---

# Future Improvements

Potential future enhancements include:
- risk scoring framework
- cross-account behavioural analysis
- device and IP clustering
- machine learning-based anomaly detection
- real-time fraud monitoring
- dashboard visualisation
