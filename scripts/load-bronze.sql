/*
==============================================================================================
Creates or modifies procedure for emptying the bronze layer tables and insert the datasets.

Insert the entire file at the same time (I give it the path to the file, 
I tell it that the data starts at the second row and is separated by a comma and 
I want the whole table to lock when sql is making this executing this for faster operation).
Informs the user of the advancement of the loading and the time it takes for every operation.

To use it you can execute:
	EXEC bronze.load_bronze
==============================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_total_time DATETIME, @end_total_time DATETIME;
	BEGIN TRY
		SET @start_total_time = GETDATE();
		PRINT '======================================================================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '======================================================================================';
	
		PRINT  char(10) +'--------------------------------------------------------------------------------------'
		PRINT 'TRUNCATING TABLES';
		PRINT '--------------------------------------------------------------------------------------';
		
		
		PRINT '>> Truncating Table : crm_cust_info';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info; /*faster than delete from operation because it does not keep logs of all deletion*/
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';
		
		PRINT '>> Truncating Table : crm_prd_info';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';
		
		PRINT '>> Truncating Table : crm_sales_details';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';
		
		PRINT '>> Truncating Table : erp_cust_az12';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';
		
		PRINT '>> Truncating Table : erp_loc_a101';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';
		
		PRINT '>> Truncating Table : erp_px_cat_g1v2';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';
		

		-- 2) insert all data at the same time for every file
		PRINT  char(10) + '--------------------------------------------------------------------------------------'
		PRINT 'LOADING CRM TABLES';
		PRINT '--------------------------------------------------------------------------------------';
	
		PRINT char(10) + '>> Loading Table : crm_cust_info';
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_cust_info	
		FROM 'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT  char(10) +'>> Loading Table : crm_prd_info';
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_prd_info	
		FROM 'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';
		
		PRINT  char(10) +'>> Loading Table : crm_sales_details';
		SET @end_time = GETDATE();
		BULK INSERT bronze.crm_sales_details	
		FROM 'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT  char(10) +'--------------------------------------------------------------------------------------'
		PRINT 'LOADING ERP TABLES';
		PRINT '--------------------------------------------------------------------------------------';
	    

		PRINT  char(10) +'>> Loading Table : erp_cust_az12';
		SET @end_time = GETDATE();
		BULK INSERT bronze.erp_cust_az12	
		FROM 'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT  char(10) +'>> Loading Table : erp_loc_a101';
		SET @end_time = GETDATE();
		BULK INSERT bronze.erp_loc_a101	
		FROM 'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT  char(10) +'>> Loading Table : erp_px_cat_g1v2';
		SET @end_time = GETDATE();
		BULK INSERT bronze.erp_px_cat_g1v2	
		FROM 'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Time : ' + CAST (DATEDIFF ( millisecond , @start_time , @end_time ) AS NVARCHAR) + ' ms';

		PRINT '--------------------------------------------------------------------------------------'
		SET @end_total_time = GETDATE();
		PRINT 'Total duration of the load of the bronze layer :' + CAST (DATEDIFF ( millisecond , @start_total_time , @end_total_time ) AS NVARCHAR) + ' ms';
		PRINT '--------------------------------------------------------------------------------------'
	END TRY

	BEGIN CATCH
		PRINT '===========================================================';
		PRINT 'ERROR occured during loading the bronze layer : '+ ERROR_MESSAGE();
		PRINT 'error number ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '===========================================================';
	END CATCH
END

-- 3) quality check (data in the correct columns and everything present with the correct amount of data)
/*
SELECT * FROM bronze.crm_cust_info
SELECT * FROM bronze.crm_prd_info
SELECT * FROM bronze.crm_sales_details WHERE sls_ord_num = 'SO43697'
SELECT * FROM bronze.erp_cust_az12
SELECT * FROM bronze.erp_loc_a101
SELECT * FROM bronze.erp_px_cat_g1v2*/
