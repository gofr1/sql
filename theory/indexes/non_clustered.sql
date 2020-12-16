USE DEMO;

DROP TABLE IF EXISTS dbo.NCItest;

CREATE TABLE dbo.NCItest (
    Id int not null,
    SomeText varchar(200) not null,
    Comments varchar(200) not null
);

CREATE UNIQUE CLUSTERED INDEX [IDX_NCItest] ON NCItest(Id);
GO

WITH cte AS (
    SELECT 1 as d
    UNION ALL
    SELECT d + 1
    FROM cte 
    WHERE d < 80000
)

INSERT INTO dbo.NCItest 
SELECT d,
       CONCAT('Random text ', d), 
       CONCAT('Random comment ', d)
FROM cte 
OPTION (MAXRECURSION  0);

CREATE NONCLUSTERED INDEX [IDX_NCItest_SomeText] ON NCItest(SomeText);
GO

SELECT * 
FROM sys.dm_db_index_physical_stats (DB_ID(N'DEMO'), OBJECT_ID(N'dbo.NCItest'), 2, NULL , 'DETAILED');

ALTER INDEX [IDX_NCItest_SomeText]ON dbo.NCItest REBUILD;

--Lets get inside othe index
DBCC IND ('DEMO', 'dbo.NCItest', 2); -- 2 for NCI
-- PagePID 1280 IndexLevel = 2  

DBCC TRACEON (3604);
DBCC PAGE('DEMO', 1, 1280, 3); --root page

DBCC PAGE('DEMO', 1, 1368, 3); -- first child page
DBCC PAGE('DEMO', 1, 1728, 3); -- second child page

DBCC TRACEOFF(3604);

-- Checking before and after index is applied

SET STATISTICS PROFILE, XML, TIME ON;

SELECT *
FROM dbo.BatchTest
WHERE Product = 'raspberry necktie L'

SET STATISTICS PROFILE, XML, TIME OFF;

--* Clustered Index Scan

--* SQL Server Execution Times:
--* CPU time = 261 ms, elapsed time = 319 ms. 

CREATE NONCLUSTERED INDEX NCI_BatchTest_Product ON dbo.BatchTest(Product)

SET STATISTICS PROFILE, XML, TIME ON;

SELECT *
FROM dbo.BatchTest
WHERE Product = 'raspberry necktie L'

SET STATISTICS PROFILE, XML, TIME OFF;

--* SQL Server Execution Times:
--* CPU time = 4 ms, elapsed time = 9 ms. 

-- Now it performs Index Seek on NCI_BatchTest_Product
-- And then Clustered Index Seek on PK_BatchTest_Id
-- With Nested Loop

SET STATISTICS PROFILE, XML, TIME ON;

SELECT *
FROM dbo.BatchTest
WHERE Product LIKE 'raspberry necktie %'

SET STATISTICS PROFILE, XML, TIME OFF;

-- Same even if we search with LIKE

--* SQL Server Execution Times:
--* CPU time = 9 ms, elapsed time = 11 ms. 