USE AdventureWorks2017;

--One of the joining tables is designated as the outer table and another one as the inner table. 
--For each row of the outer table, all the rows from the inner table are matched one by one 
--if the row matches it is included in the result-set otherwise it is ignored. 
--Then the next row from the outer table is picked up and the same process is repeated and so on.

--naive nested loops join - in which case the search scans the whole table or index
--index nested loops join - when the search can utilize an existing index to perform lookups
--temporary index nested loops join - if the optimizer creates a temporary index as part of 
--the query plan and destroys it after query execution completes

SET STATISTICS PROFILE ON;

SELECT soh.CustomerID, 
       soh.SalesOrderID, 
       sod.ProductID, 
       sod.LineTotal 
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod 
    ON soh.SalesOrderID = sod.SalesOrderID 
WHERE soh.CustomerID = 30084;

SET STATISTICS PROFILE OFF;

--If the number of records involved is large, SQL Server might choose to parallelize a nested loop 
--by distributing the outer table rows randomly among the available Nested Loops threads dynamically. 
--It does not apply the same for the inner table rows

SET STATISTICS PROFILE ON;

SELECT EmailAddressID,
       EmailAddress,
       ModifiedDate 
FROM Person.EmailAddress
WHERE EmailAddress LIKE 'sab%';

SET STATISTICS PROFILE OFF;

--If you join table variable it is always selected as outer table and this may introduce performance problems

DECLARE @someTable TABLE (
    id int PRIMARY KEY
);
WITH cte AS (
    SELECT 1 as id 
    UNION ALL
    SELECT id + 1
    FROM cte 
    WHERE id < 20000
)
INSERT INTO @someTable (id)
SELECT id 
FROM cte
OPTION (MAXRECURSION 0);

SET STATISTICS PROFILE ON;

SELECT *
FROM Person.Person p 
INNER JOIN @someTable st
    ON st.id = p.BusinessEntityID;
--OPTION (RECOMPILE); -- In that case Merge Join will be used (look at the Estimate Rows)
--If you have no PK in table variable it will use Nested Loop anyway

SET STATISTICS PROFILE OFF;


