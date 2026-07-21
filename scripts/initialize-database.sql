/*
======================================================================================================================================
Initialize the database DataWarehouse.

The script delete the database named 'DataWarehouse' if it exists, 
recreate it and creates the schemas 'bronze', 'silver' & 'gold' for the different layers.

WARNING : Execute this script will delete all data that is inside the database permenentaly.
======================================================================================================================================
*/

-- create database

USE master;
DROP DATABASE If exists DataWarehouse;
CREATE DATABASE DataWarehouse;


-- create all schemes
USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO