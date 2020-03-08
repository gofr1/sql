USE DEMO;

DROP TABLE IF EXISTS dbo.IndexTest;

CREATE TABLE dbo.IndexTest (
    Id int,
    [Value] varchar(1000)
);

WITH cte AS (
    SELECT 1 as Id,
           REPLICATE('a',1000) as [Value]
    UNION ALL
    SELECT Id + 1,
           REPLICATE('a',1000)
    FROM cte 
    WHERE Id <10000
)

INSERT INTO dbo.IndexTest (Id,[Value])
SELECT Id,
       [Value] 
FROM cte
OPTION (MAXRECURSION 0);

---------------------------------------------------

CHECKPOINT
GO

DBCC DROPCLEANBUFFERS;
DBCC FREESYSTEMCACHE ('ALL');
GO

SET STATISTICS IO ON;

SELECT Id, [Value] FROM dbo.IndexTest WHERE Id < 498

SET STATISTICS IO OFF;

DROP INDEX IF EXISTS IX_IndexTest ON dbo.IndexTest;
CREATE NONCLUSTERED INDEX IX_IndexTest ON dbo.IndexTest (Id) INCLUDE ([Value])


SELECT * 
FROM sys.dm_db_index_physical_stats  
    (DB_ID(N'DEMO'), OBJECT_ID(N'dbo.IndexTest'), NULL, NULL , 'DETAILED'); 

    SELECT i.[name] AS IndexName
    ,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
GROUP BY i.[name]
ORDER BY i.[name]