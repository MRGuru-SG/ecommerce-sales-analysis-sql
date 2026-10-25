E-COMMERCE SALES ANALYSIS USING MYSQL
======================================

Files:
1. ecommerce_sales_5000.csv - 5,000 synthetic practice records.
2. ecommerce_sales_project.sql - database/table setup and analysis queries.

IMPORTANT:
This is synthetic practice data, not real company data. Use it as a portfolio project
and clearly label it as a self-created/sample dataset.

IMPORT INTO MYSQL WORKBENCH:
1. Open MySQL Workbench and connect to your server.
2. Open ecommerce_sales_project.sql in Workbench (File > Open SQL Script), or paste
   its CREATE DATABASE / USE / CREATE TABLE section into a new query tab.
3. Execute the database and table creation statements (lightning icon).
4. In the SCHEMAS panel, right-click ecommerce_analytics > Tables.
5. Choose Table Data Import Wizard.
6. Select ecommerce_sales_5000.csv.
7. Choose existing table sales_raw, confirm comma delimiter and first row as column names.
8. Map/check columns in the same order, then import.
9. Run SELECT COUNT(*) FROM sales_raw; It should return 5000.
10. Run the analysis queries from the SQL script.

If your Workbench version does not offer importing into an existing table, use the wizard
to create a table from the CSV, then check that the columns/types match the SQL script.
