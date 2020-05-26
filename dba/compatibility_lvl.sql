USE master
GO

-- Check
SELECT name, 
       compatibility_level
FROM sys.databases
--WHERE name = 'WideWorldImporters'
GO

/*
Product                 Database  Default        Supported   
                        Engine    Compatibility  Compatibility
                        Version   Level          Level
                                  Designation    Values
SQL Server 2019 (15.x)  15 	      150            150, 140, 130, 120, 110, 100
SQL Server 2017 (14.x)  14        140            140, 130, 120, 110, 100
SQL Server 2016 (13.x)  13        130            130, 120, 110, 100
SQL Server 2014 (12.x)  12        120            120, 110, 100
SQL Server 2012 (11.x)  11        110            110, 100, 90
SQL Server 2008 R2      10.5      100            100, 90, 80
SQL Server 2008         10        100            100, 90, 80
SQL Server 2005 (9.x)   9         90             90, 80
SQL Server 2000 (8.x)   8         80             80
*/

-- Change
ALTER DATABASE DEMO
SET compatibility_level = 150 
GO