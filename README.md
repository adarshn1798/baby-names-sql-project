# US Baby Names Analysis (SQL Project)

This project explores naming trends in the United States using SQL on a dataset with over 2 million baby name records.

---

## Dataset

- Source: Maven Analytics  
- Records: 2M+  

---

## Tools Used

- MySQL  
- SQL (CTEs, Joins, Aggregations, Window Functions)  
- Git & GitHub  

---

## Key Analyses

- Most popular names by year and gender  
- Gender-neutral names over time  
- Top names by state  
- Naming trends across decades  

## How to Use

1. Create the Database in MySQL:

   CREATE DATABASE baby_names_db;

2. Import the data using the three insert scripts in order:

  - mysql -u root -p baby_names_db < insert_baby_names_1.sql
  - mysql -u root -p baby_names_db < insert_baby_names_2.sql
  - mysql -u root -p baby_names_db < insert_baby_names_3.sql

3. Run Analysis queries using:

   result_analysis.sql



