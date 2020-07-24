-- Collation used by all the databases on a SQL Server instance 
USE [master]
GO

SELECT  [NAME], 
        COLLATION_NAME
FROM sys.databases
ORDER BY DATABASE_ID ASC
GO

-- Returns a list of all the collations supported by SQL Server 2005 and above 
SELECT * 
FROM fn_helpcollations() 
GO

-- Get a collation of current db
SELECT DB_NAME() as db_name,
       SERVERPROPERTY('collation') AS collation
GO

-- Change database collation
USE [master]
GO  

ALTER DATABASE DEMO  
COLLATE SQL_Latin1_General_CP1_CI_AS 
GO  