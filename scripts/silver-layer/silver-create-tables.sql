/*
==============================================================================================
Creates table for the silver layer.

This script remove all existing silver.tables and 
then creates them with no obligatory attributes.

WARNING : Executing this script will delete permenentaly 
all data contained insinde the silver.layer tables!
==============================================================================================s
*/


USE DataWarehouse
GO
DROP TABLE IF EXISTS silver.crm_cust_info 
DROP TABLE IF EXISTS silver.crm_prd_info 
DROP TABLE IF EXISTS silver.crm_sales_details 
DROP TABLE IF EXISTS silver.erp_cust_az12 
DROP TABLE IF EXISTS silver.erp_loc_a101 
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2 

CREATE TABLE silver.crm_cust_info
(
	cst_id int NULL,
	cst_key NVARCHAR(50) NULL,
	cst_firstname NVARCHAR(50) NULL,
	cst_lastname NVARCHAR(50) NULL,
	cst_marital_status NVARCHAR(50) NULL,
	cst_gndr NVARCHAR(50) NULL,
	cst_create_date DATE NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)
GO

CREATE TABLE silver.crm_prd_info
(
	prd_id INT NULL,
	prd_key NVARCHAR(50) NULL,
	cat_id NVARCHAR(50) NULL,
	sls_prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50) NULL,
	prd_cost INT NULL,
	prd_line NVARCHAR(50) NULL,
	prd_start_dt DATE NULL, 
	prd_end_dt DATE NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)
GO

CREATE TABLE silver.crm_sales_details
(
	sls_ord_num NVARCHAR(50) NULL,
	sls_prd_key NVARCHAR(50) NULL,
	sls_cust_id INT NULL,
	sls_order_dt DATE NULL,
	sls_ship_dt DATE NULL,
	sls_due_dt DATE NULL,
	sls_sales INT NULL,
	sls_quantity INT NULL,
	sls_price INT NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)
GO


CREATE TABLE silver.erp_cust_az12
(
	CID NVARCHAR(50) NULL,
	BDATE DATE NULL,
	GEN NVARCHAR(50) NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)
GO


CREATE TABLE silver.erp_loc_a101
(
	CID NVARCHAR(50) NULL,
	CNTRY NVARCHAR(50) NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)
GO

CREATE TABLE silver.erp_px_cat_g1v2
(
	ID NVARCHAR(50) NULL,
	CAT NVARCHAR(50) NULL,
	SUBCAT NVARCHAR(50) NULL,
	MAINTENANCE NVARCHAR(50) NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)
GO
USE master