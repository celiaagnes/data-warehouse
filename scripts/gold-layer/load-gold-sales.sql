/*
======================================================================================================================================
Create a view for sales in the gold layer.

Prerequisites : Having exucuted the files load-gold-products and load-gold-customers
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

