/*
======================================================================================================================================
Create a view for customers in the gold layer.
======================================================================================================================================
*/
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


