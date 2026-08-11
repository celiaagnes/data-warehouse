/*
Empty the tables and insert the datasets that has been transformed using the bronze layer.

I used several transformations:
	Derived columns, 
	Data normalisation,
	Data standardization,
	Handling missing data,
	Handling invalid values,
	Handling unwanted spaces,
	Removing duplicates,
	etc.

To use it you can launch:
	EXEC silver.load_silver
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_total_time DATETIME, @end_total_time DATETIME;
	BEGIN TRY
		SET @start_total_time = GETDATE();
		PRINT '======================================================================================';
		PRINT 'LOADING SILVER LAYER';
		PRINT '======================================================================================';
	
		PRINT  char(10) +'--------------------------------------------------------------------------------------'
		PRINT 'LOADING CRM TABLES';
		PRINT '--------------------------------------------------------------------------------------';
		
		PRINT char(10) +char(10) +'>> Truncating Table : silver.crm_cust_info';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_cust_info
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT char(10) +'>> Inserting data into : silver.crm_cust_info ';
		SET @start_time = GETDATE();
		INSERT INTO silver.crm_cust_info 
			(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
			)

		SELECT 
		cst_id, 
		cst_key, 

		-- removing unwanted spaces for the names
		TRIM(cst_firstname) AS cst_firstname, 
		TRIM(cst_lastname) AS cst_lastname, 
		-- normalizing marital status data
		CASE UPPER(TRIM(cst_marital_status)) 
			WHEN 'M' THEN 'Married' 
			WHEN 'S' THEN 'Single'
			ELSE 'n/a' -- handling missing data
		END AS cst_marital_status, 
		-- normalizing gender data
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a'
		END AS cst_gndr,
		cst_create_date
		FROM(
		-- removing duplicates and nulls in the primary key
		SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS find_last
		FROM bronze.crm_cust_info) AS T
		WHERE find_last = 1 AND cst_id IS NOT NULL; -- filtering data to only keep most recent entry for the same costumer
		
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';


		-- Table crm_prd_info

		PRINT char(10) +'>> Truncating Table : silver.crm_prd_info';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_prd_info
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT char(10) +'>> Inserting data into : silver.crm_prd_info ';
		SET @start_time = GETDATE();
		INSERT INTO silver.crm_prd_info (
			prd_id,
			prd_key,
			cat_id,
			sls_prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
		prd_id,
		prd_key,
		--separe the product key into two useful parts
		REPLACE(SUBSTRING(prd_key, 1, 5), '-','_') AS cat_id,
		SUBSTRING(prd_key, 7, len(prd_key)) AS sls_prd_key,
		prd_nm,
		ISNULL(prd_cost, 0) AS prd_cost,
		-- normalize the line of the product to be uredestandable
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		prd_start_dt,
		-- Rule : take a day before the start of the next date as an date date 
		DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) ) AS prd_end_dt
		FROM bronze.crm_prd_info

		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		-- Table crm_sales_details

		PRINT char(10) +'>> Truncating Table : silver.crm_sales_details';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_sales_details
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT char(10) +'>> Inserting data into : silver.crm_sales_details ';
		SET @start_time = GETDATE();
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key ,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			TRIM(sls_ord_num) AS sls_ord_num, -- remove unwanted space
			TRIM(sls_prd_key) AS sls_prd_key,
			sls_cust_id,
			/* If the integers are incoherent we put them to null, if not we turn them into dates.*/
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) < 8 OR sls_order_dt > 20500101 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) /* NVARCHAR TO VARCHAR TO DATE*/
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) < 8 OR sls_ship_dt > 20500101 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) < 8 OR sls_due_dt > 20500101 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,

			/* The rules :
				if Sales is negative, zero or null, derive it using Quantity and Price
				if Price is zero or null, calculate it using Sales and Quantity
				if Price is negative, convert it to a positive value

				For that we:
					Handle invalid and missing data
					Do data type casting
			*/
			CASE 
				WHEN  sls_sales IS NULL or sls_sales <= 0 OR sls_sales != ABS(sls_price) * sls_quantity 
					THEN sls_price * sls_quantity
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price < 0 OR sls_price IS NULL 
					THEN sls_sales/ NULLIF(sls_quantity,0)
				WHEN sls_price = 0 THEN ABS(sls_price)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details


		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';



		PRINT  char(10) +'--------------------------------------------------------------------------------------'
		PRINT 'LOADING ERP TABLES';
		PRINT '--------------------------------------------------------------------------------------';
		-- #### erp_cust_az12 ####
	
		PRINT char(10) +'>> Truncating Table : silver.erp_cust_az12';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_cust_az12
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT char(10) +'>> Inserting data into : silver.erp_cust_az12 ';
		SET @start_time = GETDATE();
		INSERT INTO silver.erp_cust_az12 (
			CID,
			BDATE,
			GEN
		)
		SELECT
		-- handle foreign key
		CASE 
			WHEN TRIM(CID) LIKE 'NAS%' THEN TRIM(SUBSTRING(CID, 4, LEN(CID)))
			ELSE CID
		END AS CID,
		-- remove the birth data that occured after the current time (incoherence)
		CASE
			WHEN BDATE > GETDATE() OR BDATE < '1900-01-01' THEN NULL
			ELSE BDATE
		END AS BDATE,
		-- Normalize gender data
		CASE 
			WHEN REPLACE(UPPER(TRIM(GEN)), CHAR(13) ,'') IN ('M', 'MALE') THEN 'Male'	
			WHEN REPLACE(UPPER(TRIM(GEN)), CHAR(13) ,'') IN ('F', 'FEMALE') THEN 'Female'
			ELSE 'n/a'
		END AS GEN
		FROM bronze.erp_cust_az12 

		-- erp_loc_a101
		PRINT char(10) +'>> Truncating Table : silver.erp_loc_a101';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_loc_a101
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';


		PRINT char(10) +'>> Inserting data into : silver.erp_loc_a101 ';
		SET @start_time = GETDATE();
		INSERT INTO silver.erp_loc_a101 (CID, CNTRY)
		SELECT 
		REPLACE(CID, '-', '') AS CID,
		/* normalizing data */
		CASE 
			WHEN REPLACE(TRIM(CNTRY), CHAR(13), '') IN ('USA','United States', 'US') THEN 'USA'
			WHEN REPLACE(TRIM(CNTRY), CHAR(13), '') = 'DE' THEN 'Germany'
			WHEN LEN(REPLACE(TRIM(CNTRY), char(13), '')) = 0 THEN 'n/a'
			ELSE REPLACE(TRIM(CNTRY), CHAR(13), '')
		END AS CNTRY
		FROM bronze.erp_loc_a101

		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		-- erp_px_cat_g1v2

		PRINT char(10) +'>> Truncating Table : silver.erp_px_cat_g1v2';
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT char(10) +'>> Inserting data into : silver.erp_px_cat_g1v2 ';
		SET @start_time = GETDATE();
		INSERT INTO silver.erp_px_cat_g1v2 (
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		)
		SELECT
			ID,
			TRIM(CAT),
			TRIM(SUBCAT),
			MAINTENANCE
		/*only take id that are present in the foreign table : coherence*/
		FROM (SELECT * FROM bronze.erp_px_cat_g1v2 WHERE ID IN (SELECT cat_id FROM silver.crm_prd_info)) AS T

		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		SET @end_total_time = GETDATE();		
		PRINT '--------------------------------------------------------------------------------------'
		PRINT 'Total duration of the load of the bronze layer :' + CAST (DATEDIFF ( millisecond , @start_total_time , @end_total_time ) AS NVARCHAR) + ' ms';
		PRINT '--------------------------------------------------------------------------------------'
	
	END TRY

	BEGIN CATCH
		PRINT '===========================================================';
		PRINT 'ERROR occured during loading the silver layer : '+ ERROR_MESSAGE();
		PRINT 'error number ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '===========================================================';
	END CATCH
END
