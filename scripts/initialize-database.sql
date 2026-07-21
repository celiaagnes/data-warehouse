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