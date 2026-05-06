# Fraud Analysis in Banking Transactions

## Project Description

This project implements a **scenario-driven fraud detection approach** (Fraud Data Analytics Methodology) using banking transaction data.

The objective of the analysis is to identify transactional patterns associated with **unauthorized use of customer accounts**, including:
- active account takeover
- exploitation of dormant accounts

The project demonstrates how a theoretical fraud detection methodology can be translated into a **practical SQL-based analytical testing framework**.

---

## Project Contents

- Bank transactions dataset:  
`./bank_transactions_data.csv`

- Methodology and analytical report:  
`./fraud-data-analytics.pdf`

- SQL analytical tests and detection logic:  
`./fraud-data-analytics.sql`

---

## Objective

Determine whether bank accounts demonstrate behavioural patterns consistent with fraud scenarios involving unauthorized access and fund extraction.

Important: the purpose of the project is not to prove fraud, but to **identify transactions with elevated risk indicators**.

---

## Methodology

The project follows a **scenario-driven approach**:

1. Define a fraud scenario  
2. Identify concealment strategies  
3. Develop risk indicators (*red flags*)  
4. Translate indicators into SQL-based analytical tests  

The analysis is built not from the data itself, but from the **underlying logic of how fraud is committed**.

---

## Fraud Scenarios

### Scenario 1 — Active Account Takeover

An external actor gains access to an active customer account and performs multiple transactions within a short period of time to rapidly extract funds.

**Key indicators:**
- elevated transaction frequency  
- unusually high cumulative transaction volume  
- transaction fragmentation across multiple operations  

---

### Scenario 2 — Dormant Account Exploitation

An external actor gains access to a dormant account and initiates transactions after a prolonged period of inactivity.

**Key indicators:**
- long gaps between transactions  
- reactivation following prolonged inactivity  
- elevated login attempt counts  

---

## Technologies Used

- SQL (MySQL)  
- Transaction Data Analysis  
- Fraud Data Analytics Methodology  

---

## Data

The project uses the public dataset:

[Bank Transactions Dataset for Fraud Detection (Kaggle)](https://www.kaggle.com/datasets/thuandao/bank-transactions-dataset-for-fraud-detection)

- ~50,000 transactions  
- simulated banking activity  
- includes transaction, device, IP, and login attempt data  

---

## Analytical Logic

For each scenario:

- a behavioural baseline is established for each account  
- baseline metrics are calculated (averages, frequency, intervals)  
- SQL-based analytical tests are applied to identify deviations from expected behaviour  

A cumulative **risk score** is then generated based on identified indicators.

---

## Cumulative Analysis

Transactions are assessed based on combinations of risk indicators.

Particular attention is given to cases where:
- a transaction matches multiple fraud scenarios simultaneously  
- behavioural and temporal anomalies occur together  

Such combinations are considered the strongest indicators of potentially suspicious activity.

---

## Limitations

- absence of confirmed fraud labels  
- partial absence of precise transaction timestamps  
- dataset is simulated rather than real-world  
