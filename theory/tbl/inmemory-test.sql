USE [master]
GO

DROP DATABASE IF EXISTS InMemoryTest;
GO

CREATE DATABASE InMemoryTest;
GO

--Create a filegroup
ALTER DATABASE InMemoryTest
ADD FILEGROUP fg_InMemoryTest
CONTAINS MEMORY_OPTIMIZED_DATA
GO

--Add a file to filegroup
ALTER DATABASE InMemoryTest
ADD FILE (
    Name = N'InMemoryTest_InMemoryTest',
    FileName='/var/opt/mssql/data/InMemoryTest_InMemoryTest'
)
TO FILEGROUP fg_InMemoryTest
GO

USE InMemoryTest
GO
--Check filegroups od DB
SELECT * 
FROM sys.filegroups
GO 

--Create a memory-optimized table
DROP TABLE IF EXISTS dbo.InMemoryTest 
GO

CREATE TABLE dbo.InMemoryTest (
    Id INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED, --In memory tables should have NONCLUSTERED PK
    [Name] VARCHAR(1000) NOT NULL
) WITH (
    MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_ONLY
)
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

--* schema_name  table_name    is_memory_optimized    durability_desc  create_date              modify_date
--* dbo          InMemoryTest  1                      SCHEMA_ONLY      2021-03-17 12:25:38.217  2021-03-17 12:25:38.217

SELECT name,
       type_desc,
       [size] * 8 / 1024 AS size_mb 
FROM sys.database_files;
GO
--* name                        type_desc   size_mb
--* InMemoryTest                ROWS        8
--* InMemoryTest_log            LOG         8
--* InMemoryTest_InMemoryTest   FILESTREAM  105

DECLARE @lorem VARCHAR(1000) = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

WITH cte AS (
    SELECT 1 as Id,
           @lorem + CAST(NEWID() as varchar(50)) as [Name]
    UNION ALL
    SELECT Id + 1,
           @lorem + CAST(NEWID() as varchar(50))
    FROM cte
    WHERE Id < 100000
)

INSERT INTO dbo.InMemoryTest ([Name])
SELECT [Name]
FROM cte
OPTION (MAXRECURSION 0)
GO

SELECT name,
       type_desc,
       [size] * 8 / 1024 AS size_mb 
FROM sys.database_files;
GO
--* name                        type_desc   size_mb
--* InMemoryTest                ROWS        8
--* InMemoryTest_log            LOG         8
--* InMemoryTest_InMemoryTest   FILESTREAM  105

SELECT COUNT(*) as cnt
FROM dbo.InMemoryTest WITH(NOLOCK);
GO
--* cnt
--* 100000

CHECKPOINT;
GO 30

SELECT name,
       type_desc,
       [size] * 8 / 1024 AS size_mb 
FROM sys.database_files;
GO
--* name                        type_desc   size_mb
--* InMemoryTest                ROWS        8
--* InMemoryTest_log            LOG         8
--* InMemoryTest_InMemoryTest   FILESTREAM  230