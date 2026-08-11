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