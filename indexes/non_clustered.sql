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