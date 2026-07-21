/* insert the entire file at the same time: I give it the path to the file, 
I tell it that the data starts at the second row and is separated by a comma and 
I want the whole table to lock when sql is making this executing this for faster operation.*/

BULK INSERT  bronze.crm_cust_info	
FROM 'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_crm\cust_info.csv'
WITH (
	FIRSTROW = 2,
	--LASTROW = (SELECT len(content.BulkColumn) FROM OPENROWSET(BULK N'C:\Users\Célia\Documents\Projets_persos\data-warehouse\datasets\source_crm\cust_info.csv', SINGLE_NCLOB) AS content)),
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	TABLOCK
);

-- quality check (data in the correct columns)

SELECT * FROM bronze.crm_cust_info