USE AdventureWorks2017;

--Merge join requires both inputs to be sorted on join keys/merge columns,
--or both input tables have clustered indexes on the column that joins the tables
--and it also requires at least one equijoin (equals to) expression/predicate.

--Because the rows are pre-sorted, a Merge join immediately begins the matching process. 
--It reads a row from one input and compares it with the row of another input. 
--If the rows match, that matched row is considered in the result-set 
--then it reads the next row from the input table, does the same comparison/match and so on
--or else the lesser of the two rows is ignored and the process continues this way until 
--all rows have been processed.

--A Merge join performs better when joining large input tables (pre-indexed / sorted) 
--as the cost is the summation of rows in both input tables as opposed to the Nested 
--Loops where it is a product of rows of both input tables. 

SET STATISTICS PROFILE ON;

SELECT soh.CustomerID, 
       soh.SalesOrderID, 
       sod.ProductID, 
       sod.LineTotal 
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod 
    ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID > 100;

SET STATISTICS PROFILE OFF;

--Another sample
USE DEMO;

DROP TABLE IF EXISTS dbo.MergeTableA;
DROP TABLE IF EXISTS dbo.MergeTableB;

CREATE TABLE dbo.MergeTableA (
    i int not null,
    n int not null,
    CONSTRAINT [PK_MergeTableA_i] PRIMARY KEY (i)
);
CREATE TABLE dbo.MergeTableB (
    i int not null,
    n int not null,
    CONSTRAINT [PK_MergeTableB_i] PRIMARY KEY (i)
);

WITH cte AS (
    SELECT 1 as i 
    UNION ALL
    SELECT i + 1
    FROM cte 
    WHERE i < 1500
)
INSERT INTO dbo.MergeTableA 
SELECT i, i FROM cte OPTION (MAXRECURSION 0);

INSERT INTO dbo.MergeTableB
SELECT i, n FROM dbo.MergeTableA;


SET STATISTICS PROFILE ON;
SET STATISTICS IO ON;

SELECT *
FROM dbo.MergeTableA a
INNER JOIN dbo.MergeTableB b
    ON a.n = b.n
OPTION (MERGE JOIN); --Hash join by default
--*Worktable is introduced because SQL Sever is not sure about duplicates in tables
--*and also you can see SORT operator in plan
--*with many-to-many = true

SET STATISTICS IO OFF;
SET STATISTICS PROFILE OFF;

--Lets create an index on table B

DROP INDEX IF EXISTS [IDX_NCI_MergeTableA_n] ON dbo.MergeTableA;
CREATE UNIQUE NONCLUSTERED INDEX [IDX_NCI_MergeTableA_n] ON dbo.MergeTableA(n);
UPDATE STATISTICS dbo.MergeTableA WITH FULLSCAN;

DROP INDEX IF EXISTS [IDX_NCI_MergeTableB_n] ON dbo.MergeTableB;
CREATE UNIQUE NONCLUSTERED INDEX [IDX_NCI_MergeTableB_n] ON dbo.MergeTableB(n);
UPDATE STATISTICS dbo.MergeTableB WITH FULLSCAN;

--Check it out
SET STATISTICS PROFILE ON;
SET STATISTICS IO ON;
SET STATISTICS XML ON;

SELECT a.*, b.*
FROM dbo.MergeTableA a
INNER JOIN dbo.MergeTableB b
    ON a.n = b.n;
--*Now we have merge join with many-to-many = false, because both tables are unique

SET STATISTICS IO OFF;
SET STATISTICS PROFILE OFF;
SET STATISTICS XML OFF;