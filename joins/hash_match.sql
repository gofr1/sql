USE AdventureWorks2017;

--A Hash join is normally used when input tables are quite large and no adequate indexes exist on them. 
--A Hash join is performed in two phases; the Build phase and the Probe phase 
--and hence the hash join has two inputs i.e. build input and probe input. 
--The smaller of the inputs is considered as the build input (to minimize the memory requirement to store a hash table discussed later) 
--and obviously the other one is the probe input.

--During the build phase, joining keys of all the rows of the build table are scanned. 
--Hashes are generated and placed in an in-memory hash table. Unlike the Merge join, it's blocking (no rows are returned) until this point.

--During the probe phase, joining keys of each row of the probe table are scanned. 
--Again hashes are generated (using the same hash function as above) and compared against the corresponding hash table for a match.

DROP TABLE IF EXISTS Sales.SalesOrderHeaderHashTest;
DROP TABLE IF EXISTS Sales.SalesOrderDetailHashTest;
--Generate a table with no indexes
SELECT * INTO Sales.SalesOrderHeaderHashTest FROM Sales.SalesOrderHeader;
SELECT * INTO Sales.SalesOrderDetailHashTest FROM Sales.SalesOrderDetail;


SET STATISTICS PROFILE ON;
--Here there will be two table sacns and hash match will be used
SELECT soh.CustomerID, 
       soh.SalesOrderID, 
       sod.ProductID, 
       sod.LineTotal 
FROM Sales.SalesOrderHeaderHashTest soh
INNER JOIN Sales.SalesOrderDetailHashTest sod 
    ON soh.SalesOrderID = sod.SalesOrderID 
WHERE soh.CustomerID = 30084;

SET STATISTICS PROFILE OFF;

--A Hash function requires significant amount of CPU cycles to generate hashes and memory resources to store the hash table. 
--If there is memory pressure, some of the partitions of the hash table are swapped to tempdb and whenever there is a need 
--(either to probe or to update the contents) it is brought back into the cache. 
--To achieve high performance, the query optimizer may parallelize a Hash join to scale better than any other join.

--In-memory Hash Join - in which case enough memory is available to store the hash table
--Grace Hash Join - in which case the hash table cannot fit in memory and some partitions are spilled to tempdb
--Recursive Hash Join - in which case a hash table is so large the optimizer has to use many levels of hash joins.

SET STATISTICS XML ON;

SELECT p.FirstName, 
       p.LastName, 
       pp.PhoneNumber 
FROM Person.Person p
INNER JOIN Person.PersonPhone pp 
    ON p.BusinessEntityID = pp.BusinessEntityID ;

SET STATISTICS XML OFF;