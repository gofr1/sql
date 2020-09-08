USE AdventureWorks2017;

--The Tipping Point
-----------------------------------------------------------------------
--The point at which the number of page reads required by the RID lookups 
--exceeds the total number of data pages in the table, a clustered index 
--scan becomes less expensive than the non clustered index seek. 
--When the tipping point is exceeded, the optimizer will usually prefer 
--a scan of the clustered index instead of a nonclustered index seek.

--The tipping point is the threshold at which a query plan will “tip” from 
--seeking a non-covering nonclustered index to scanning the clustered index or heap.

SET STATISTICS IO ON;
SET STATISTICS PROFILE ON;

--With a non clustered index the data is retrieved one row at a time 
--with a series of single-page io’s called row id lookups or RID lookups. 
--A page returned by RID lookup might contain several qualifying rows. 
--But if so, it will be read several times, once for each qualifying row.

SELECT LineTotal
FROM sales.SalesOrderDetail  --logical reads 1247
--WITH (index=IX_SalesOrderDetail_ProductID) --logical reads 14379,
WHERE ProductID = 870;

SET STATISTICS IO OFF;
SET STATISTICS PROFILE OFF;

USE DEMO;

DROP TABLE IF EXISTS dbo.TippingPoint;

CREATE TABLE dbo.TippingPoint (
    [Id] int not null, --4 bytes
    [Name] varchar(100), --100+2 bytes
    [Address] varchar(100), --100+2 bytes
    [Comments] varchar(185), --185+2 bytes
    [SomeValue] int, --4 bytes
    CONSTRAINT [PK_TippingPoint_id] PRIMARY KEY (Id)
);
--399 bytes + 7 bytes so 8060/406 = 19.85 rows per page
dbcc showcontig ('TippingPoint') with tableresults

WITH cte AS (
    SELECT 1 [id],
           REPLICATE('a', 100) [name],
           REPLICATE('b', 100) [addr],
           REPLICATE('c', 185) [comm]
    UNION ALL
    SELECT [id] + 1,
           [name],
           [addr],
           [comm]
    FROM cte
    WHERE id < 80000
)

INSERT INTO dbo.TippingPoint
SELECT [id],
       [name],
       [addr],
       [comm],
       id
FROM cte OPTION (MAXRECURSION 0);

CREATE UNIQUE NONCLUSTERED INDEX [IDX_TippingPoint] ON dbo.TippingPoint(SomeValue);

SELECT index_type_desc, 
       page_count, 
       record_count
FROM sys.dm_db_index_physical_stats (DB_ID(N'DEMO'), OBJECT_ID(N'dbo.TippingPoint'), NULL, NULL , 'DETAILED')
WHERE index_level = 0; 

--For table consist of 4211 pages 

SET STATISTICS IO ON;
SET STATISTICS PROFILE ON;
SET STATISTICS TIME ON;

--SELECT * FROM dbo.TippingPoint; --logical reads 4227 Clustered Index Scan
SELECT *
FROM dbo.TippingPoint
WHERE SomeValue < 1117; --logical reads 3430 (index seek + ci -> nested loop) CPU time = 13 ms, elapsed time = 14 ms. 
--WHERE SomeValue < 1118;  --logical reads 4227 (ci scan) CPU time = 14 ms, elapsed time = 16 ms. 
--With force use of NCI we will have logical reads 245152 and CPU time = 369 ms, elapsed time = 1112 ms. 
--WITH (INDEX=IDX_TippingPoint) WHERE SomeValue < 80001;

SET STATISTICS IO OFF;
SET STATISTICS PROFILE OFF;
SET STATISTICS TIME OFF;

--Lets reduce table

UPDATE dbo.TippingPoint
SET [Name] = LEFT([Name], 10),
    [Address] = LEFT([Address], 10),
    [Comments]= LEFT([Comments], 10);

ALTER TABLE dbo.TippingPoint
ALTER COLUMN [Name] varchar(10);
ALTER TABLE dbo.TippingPoint
ALTER COLUMN [Address] varchar(10);
ALTER TABLE dbo.TippingPoint
ALTER COLUMN [Comments] varchar(10);

ALTER TABLE dbo.TippingPoint REBUILD;

dbcc showcontig ('TippingPoint') with tableresults

--For table that consist of 547 pages

SET STATISTICS IO ON;
SET STATISTICS PROFILE ON;
SET STATISTICS TIME ON;

--SELECT * FROM dbo.TippingPoint; -- logical reads 548 Clustered Index Scan CPU time = 84 ms, elapsed time = 95 ms. 
SELECT *
FROM dbo.TippingPoint
WHERE SomeValue < 191; --logical reads 402 (index seek + ci -> nested loop) CPU time = 4 ms, elapsed time = 2 ms. 
--WHERE SomeValue < 192;  --logical reads 548 (ci scan) CPU time = 24 ms, elapsed time = 25 ms.  
--With force use of NCI we will have logical reads 165152and CPU time = 240 ms, elapsed time = 254 ms. 
--WITH (INDEX=IDX_TippingPoint) WHERE SomeValue < 80001;

SET STATISTICS IO OFF;
SET STATISTICS PROFILE OFF;
SET STATISTICS TIME OFF;