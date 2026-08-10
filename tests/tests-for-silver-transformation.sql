-- Quality Check : check for nulls and duplicates in primary key
-- Expectation : no result



-- #### Table crm_cust_info ####

/*SELECT * from silver.crm_cust_info */

SELECT cst_id, COUNT(cst_id) AS 'nb id'
FROM silver.crm_cust_info
GROUP BY cst_id HAVING COUNT(*) > 1

-- check for unwanted spaces
-- expectation : no result
SELECT *
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


--check binarity of marital status and gender
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info




-- ##### crm_prd_info ####

/*SELECT * FROM silver.crm_prd_info */

-- find duplicates or nulls in primary key
SELECT prd_id, COUNT(prd_id) AS flag_duplicates
FROM silver.crm_prd_info
GROUP BY prd_id HAVING COUNT(*) > 1 or prd_id IS NULL;

-- no unwanted spaces
SELECT *
FROM silver.crm_prd_info 
where prd_nm != TRIM (prd_nm)


-- only few results, no weird ones
SELECT DISTINCT prd_line
FROM silver.crm_prd_info 

--no nulls or negative numbers
SELECT *
FROM silver.crm_prd_info 
WHERE prd_cost IS NULL or prd_cost<0

--start date must be before end date
SELECT *
FROM silver.crm_prd_info 
WHERE prd_start_dt > prd_end_dt


-- #### crm_sales_details ###

-- no unwanted spaces
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

SELECT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)


-- no negative id and dates
SELECT sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id <0 

-- ship date is before due date

SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt > sls_due_dt

-- make sure the foreign key exists in their own tables

SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN ( SELECT sls_cust_id FROM silver.crm_cust_info)

SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN ( SELECT sls_prd_key FROM silver.crm_prd_info)



SELECT sls_sales,sls_quantity, sls_price 
FROM silver.crm_sales_details 
WHERE 
sls_sales <0 or sls_sales is null 
or sls_sales != sls_quantity*sls_price 
or sls_quantity<0 or sls_quantity is null 
or sls_price<0 or sls_price is null
ORDER BY sls_sales,sls_quantity, sls_price 


-- erp_cust_az12

/*Select * from silver.erp_cust_az12 */
-- cid must be a foreign key to crm_cust_info with cst_key attribute
SELECT CID
FROM silver.erp_cust_az12 
WHERE CID NOT IN (SELECT cst_key from silver.crm_cust_info)

-- cid is unique 
SELECT CID , COUNT(CID) FROM silver.erp_cust_az12 GROUP BY CID HAVING COUNT (*) >1
SELECT * FROM silver.erp_cust_az12 WHERE CID IS NULL
--  birth dates cannot be after current date

SELECT BDATE FROM silver.erp_cust_az12 WHERE BDATE > GETDATE() OR BDATE < '1900-01-01'

-- Gender must be binary (having an 'other' entry would be preferable but the source system chose not to implement this)
SELECT DISTINCT GEN FROM silver.erp_cust_az12



-- #### TABLE erp_loc_a101 ####

/*SELECT * FROM silver.erp_loc_a101*/
-- cid must be in attribute cst_key of crm_cust_info table

SELECT CID FROM silver.erp_loc_a101 WHERE CID NOT IN (SELECT cst_key from silver.crm_cust_info)

-- only correhent countries are present or n/a if unnknown
SELECT DISTINCT TRIM(CNTRY) FROM silver.erp_loc_a101



-- #### Table erp_px_cat_g1v2 ####


/*SELECT * FROM silver.erp_px_cat_g1v2*/

-- ID must be foreign key and present in the other table


SELECT * FROM silver.erp_px_cat_g1v2 WHERE ID NOT IN (SELECT cat_id FROM silver.crm_prd_info)

-- maintenance must only be 'Yes' or 'No'
SELECT DISTINCT MAINTENANCE FROM silver.erp_px_cat_g1v2