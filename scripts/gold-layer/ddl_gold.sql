/*
======================================================================================================================================
DDL script : creates or alters Gold Views.
======================================================================================================================================
The gold layer represents the final dimension and fact tables (star schema)

Each view makes data transformation and data aggregation to ensure business-ready dataset.

Usages:
	- These views can be used for analytics and reporting.

*/






/*
======================================================================================================================================
Create a view for customers in the gold layer.
======================================================================================================================================
*/
USE DataWarehouse
GO

CREATE OR ALTER VIEW gold.dim_costumers AS 
SELECT 

	ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, -- surrogate key
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number, 

	ci.cst_firstname AS first_name, 
	ci.cst_lastname AS last_name, 
	cy.CNTRY AS country,
	ci.cst_marital_status AS marital_status,

	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --crm is the Master for gender info
		ELSE COALESCE(ce.GEN, 'n/a')
	END AS gender,
	ce.BDATE AS birth_date,
	ci.cst_create_date AS create_date
	/*we do not take create date because it is only for the silver layer*/
FROM silver.crm_cust_info ci
LEFT OUTER JOIN silver.erp_cust_az12 ce ON ce.CID = ci.cst_key
LEFT OUTER JOIN silver.erp_loc_a101 cy ON cy.CID = ci.cst_key
GO

/*
======================================================================================================================================
Create a view for products in the gold layer.
======================================================================================================================================
*/
CREATE OR ALTER VIEW gold.dim_products AS
SELECT 

	
	ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_key) AS product_key, --surrogate key
	pr.prd_id AS product_id,
	pr.sls_prd_key AS product_number,
	pr.prd_nm AS product_name,

	pr.cat_id AS category_id,
	px.CAT AS category,
	px.SUBCAT AS subcategory,
	px.MAINTENANCE AS maintenance,

	pr.prd_cost AS cost,
	pr.prd_line AS product_line,
	pr.prd_start_dt AS date_start

FROM silver.crm_prd_info pr
LEFT OUTER JOIN silver.erp_px_cat_g1v2 px ON pr.cat_id = px.ID
WHERE pr.prd_end_dt IS NULL -- we only keep current products
GO


/*
======================================================================================================================================
Create a view for sales in the gold layer.
======================================================================================================================================
*/
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
	--dimension keys
	sales.sls_ord_num AS order_number,
	prd.product_key,
	cust.customer_key,

	--measures
	sales.sls_sales AS sales_amount,
	sales.sls_quantity AS quantity,
	sales.sls_price AS price,

	--dates
	sales.sls_order_dt AS order_date,
	sales.sls_ship_dt AS ship_date,
	sales.sls_due_dt AS due_date

FROM silver.crm_sales_details sales
LEFT OUTER JOIN gold.dim_costumers cust ON sales.sls_cust_id = cust.customer_id
LEFT OUTER JOIN gold.dim_products prd ON sales.sls_prd_key = prd.product_number
GO



USE master
GO