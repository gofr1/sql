USE [master];

DROP DATABASE IF EXISTS ShrinkTest;

CREATE DATABASE ShrinkTest;

USE ShrinkTest;

DROP TABLE IF EXISTS dbo.Chunk;

CREATE TABLE dbo.Chunk (
    id int IDENTITY(1,1) not null,
    chunk varchar(200) not null
);

WITH cte AS (
    SELECT 1 as d, 
           REPLICATE('a',200) t
    UNION ALL
    SELECT d+1,
           t 
    FROM cte
    WHERE d < 2000
)
INSERT INTO dbo.Chunk (chunk)
SELECT t 
FROM cte
OPTION (MAXRECURSION 2000);


DROP TABLE IF EXISTS dbo.IndexedChunk;

CREATE TABLE dbo.IndexedChunk (
    id int IDENTITY(1,1) not null,
    [value] varchar(1600) not null
);

CREATE UNIQUE CLUSTERED INDEX [IDX_IndexedChunk_id] ON dbo.IndexedChunk([id]);
CREATE NONCLUSTERED INDEX [IDX_NCI_IndexedChunk_value] ON dbo.IndexedChunk([value]);

WITH cte AS (
    SELECT 1 as d, 
           REPLICATE('b',1600) t
    UNION ALL
    SELECT d+1,
           t 
    FROM cte
    WHERE d < 2000
)
INSERT INTO dbo.IndexedChunk ([value])
SELECT t 
FROM cte
OPTION (MAXRECURSION 2000);

--Let's check space used by table (table_properties.sql)

--* TableName     SchemaName  RowCnt  TotalSpaceKB  UsedSpaceKB UnusedSpaceKB
--* Chunk         dbo         2000    520           480         40
--* IndexedChunk  dbo         4000    9552          9440        112
-- RowCount is doubled for IndexedChunk because of 2 indexes

--Now lets check index fragmentation
SELECT index_type_desc,
       avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (
    DB_ID(N'ShrinkTest'), 
    OBJECT_ID(N'dbo.IndexedChunk'), 
    NULL, 
    NULL , 
    'LIMITED'
);

--* index_type_desc     avg_fragmentation_in_percent
--* CLUSTERED INDEX     0.5
--* NONCLUSTERED INDEX  49.5

--Now lets drop Chunk table
DROP TABLE IF EXISTS dbo.Chunk;
--The file size of this database will not change after dropping
--* The size is 72.000000 MB

--Now we will shrink database
DBCC SHRINKDATABASE (ShrinkTest);
--*The file size of database will be less than it was before shrink 
--*12.250000 MB


--Now lets check index fragmentation again
SELECT index_type_desc,
       avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (
    DB_ID(N'ShrinkTest'), 
    OBJECT_ID(N'dbo.IndexedChunk'), 
    NULL, 
    NULL , 
    'LIMITED'
);

--*index_type_desc     avg_fragmentation_in_percent
--*CLUSTERED INDEX     58.5
--*NONCLUSTERED INDEX  79

--Rebuild indexes to get rid of fragmentation
ALTER INDEX [IDX_IndexedChunk_id] ON dbo.IndexedChunk REBUILD;
ALTER INDEX [IDX_NCI_IndexedChunk_value] ON dbo.IndexedChunk REBUILD;

--*Database size is 76.250000 MB now