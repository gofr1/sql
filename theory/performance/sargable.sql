--! Sargable is a word that concatenates the three words: search, argument and able.
-- 
-- As per wikipedia SARGable is defined as “In relational databases, a condition (or predicate) in a query 
-- is said to be sargable if the DBMS engine can take advantage of an index to speed up the execution of the query. 
-- The term is derived from a contraction of Search ARGument ABLE”
-- 
-- Advantage of sargable queries include:
--   consuming less system resources
--   speeding up query performance
--   using indexes more effectively

--! In general you should not use functions on the columns in where statement

USE DEMO;

SET STATISTICS IO, TIME, PROFILE ON;

SELECT * 
FROM dbo.SearchARGumentABLE
WHERE YEAR(OrderDate) = 2000 --! Index Scan

--* SQL Server Execution Times:
--* CPU time = 66 ms, elapsed time = 73 ms. 

-- The SQL optimizer can't use an index on OrderDate, even if one exists. 
-- It will literally have to evaluate this function for every row of the table. Much better to use:

SELECT * 
FROM dbo.SearchARGumentABLE
WHERE OrderDate >= '01-01-2000' AND OrderDate < '01-01-2001' --? Index Seek
	
--* SQL Server Execution Times:
--* CPU time = 4 ms, elapsed time = 3 ms. 

-- Both will have almost same plan, but time of execution will be different
--! bad way
SELECT *
FROM dbo.NCItest
WHERE LEFT(SomeText,13) = 'Random Text 1'

--* SQL Server Execution Times:
--* CPU time = 67 ms, elapsed time = 71 ms.

--? good way
SELECT *
FROM dbo.NCItest
WHERE SomeText LIKE 'Random Text 1%'

--* SQL Server Execution Times:
--* CPU time = 31 ms, elapsed time = 31 ms. 
 
SET STATISTICS IO, TIME, PROFILE OFF;


--Bad: Select ... WHERE SUBSTRING(DealerName,4) = 'Ford'
--Fixed: Select ... WHERE DealerName Like 'Ford%'

--Bad: Select ... WHERE DateDiff(mm,OrderDate,GetDate()) >= 30
--Fixed: Select ... WHERE OrderDate < DateAdd(mm,-30,GetDate()) 

USE AdventureWorks2017;

SET STATISTICS PROFILE, XML, IO, TIME ON;

--! This queries are not sargable – sql server couldn’t leverage the indexes to do an index seek.

SELECT *
FROM Production.Product
WHERE [Name] like '%thin%';
--*   |--Clustered Index Scan(OBJECT:([AdventureWorks2017].[Production].[Product].[PK_Product_ProductID]), WHERE:([AdventureWorks2017].[Production].[Product].[Name] like N'%thin%'))

SELECT *
FROM Production.Product
WHERE [Name] like '%nut%';
--*   |--Clustered Index Scan(OBJECT:([AdventureWorks2017].[Production].[Product].[PK_Product_ProductID]), WHERE:([AdventureWorks2017].[Production].[Product].[Name] like N'%nut%'))


SET STATISTICS PROFILE, XML, IO, TIME OFF;