USE [master]
GO

--Create a filegroup
ALTER DATABASE DEMO
ADD FILEGROUP DemoInMemory
CONTAINS MEMORY_OPTIMIZED_DATA
GO

--Add a file to filegroup
ALTER DATABASE DEMO
ADD FILE (Name = N'DemoInMemory00', FileName='/var/opt/mssql/data/DemoInMemory00')
TO FILEGROUP DemoInMemory
GO

USE DEMO
GO
--Check filegroups od DB
SELECT * 
FROM sys.filegroups
GO 

--Create a memory-optimized table
DROP TABLE IF EXISTS dbo.Test 
GO

CREATE TABLE dbo.Test (
    Id INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED, --In memory tables should have NONCLUSTERED PK
    [Name] VARCHAR(50) NOT NULL,
    INDEX IX_CS_Test CLUSTERED COLUMNSTORE --But we can add clustered columnstore index
) WITH (MEMORY_OPTIMIZED=ON) -- DURABILTY = SCHEMA_AND_DATA (is default)
GO

--You can rebuild/reorginize index online w/o interupting users
ALTER INDEX IX_CS_Test ON dbo.Test REBUILD WITH (ONLINE = ON)
GO

--Get a list of all tables and check if there are mem-opt tables
SELECT SCHEMA_NAME(schema_id) schema_name,
       [name] table_name,
       is_memory_optimized,
       durability_desc,
       create_date,
       modify_date
FROM sys.tables
GO