USE AdventureWorks2017;

-- The main 3 types of joins are:
-- * Cross (Cartesian)
-- * Inner
-- * Outer (LEFT, RIGHT, FULL)
-- * Semi and Anti-Semi (EXSISTS, IN)
-- * Cross apply (usualy with TVF)


--? CROSS
--! PhysicalOp="Nested Loops" LogicalOp="Inner Join"
--! Warnings NoJoinPredicate="1"
-- 109 rows in that table so we will get 109 * 109 = 11881 rows
SET STATISTICS XML ON;
SET STATISTICS PROFILE ON;

SELECT CONCAT(f.CurrencyCode,'-',t.CurrencyCode) CurrencyExchange
FROM Sales.CountryRegionCurrency f 
CROSS JOIN Sales.CountryRegionCurrency t;


--? INNER
--! PhysicalOp="Merge Join" LogicalOp="Inner Join"
--! InnerSideJoinColumn - SalesOrderDetail.SalesOrderID
--! OuterSideJoinColumns - SalesOrderHeader.SalesOrderID
-- SalesOrderHeader has less rows so it was choosen to be an Outer table
SELECT h.SalesOrderID,
       h.SalesOrderNumber,
       d.OrderQty,
       d.UnitPrice
FROM Sales.SalesOrderHeader h 
INNER JOIN Sales.SalesOrderDetail d 
    ON h.SalesOrderID = d.SalesOrderID;
--If you change the tables places in statement nothing will change


--? OUTER
--! PhysicalOp="Merge Join" LogicalOp="Left Outer Join" 
--! InnerSideJoinColumn - SalesOrderHeader.CustomerID
--! OuterSideJoinColumns - Customer.CustomerID
-- Customer has less rows so it was choosen to be an Outer table

SELECT c.CustomerID, 
       h.SalesOrderNumber
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h 
    ON c.CustomerID = h.CustomerID;
-- If you switch tables places you need to use another join to get same result
SELECT c.CustomerID, 
       h.SalesOrderNumber
FROM Sales.SalesOrderHeader h 
RIGHT JOIN Sales.Customer c 
    ON c.CustomerID = h.CustomerID;

--! PhysicalOp="Merge Join" LogicalOp="Right Outer Join" 
--! InnerSideJoinColumn - SalesOrderHeader.CustomerID
--! OuterSideJoinColumns - Customer.CustomerID
-- Customer has less rows so it was choosen to be an Outer table again
SELECT c.CustomerID, 
       h.SalesOrderNumber
FROM Sales.Customer c 
RIGHT JOIN Sales.SalesOrderHeader h 
    ON c.CustomerID = h.CustomerID;
-- If you switch tables places you need to use another join to get same result
SELECT c.CustomerID, 
       h.SalesOrderNumber
FROM Sales.SalesOrderHeader h
LEFT JOIN  Sales.Customer c 
    ON c.CustomerID = h.CustomerID;

--! PhysicalOp="Hash Match" LogicalOp="Full Outer Join"
--! HashKeysBuild - ProductCategory.ProductCategoryID
--! HashKeysProbe - Product.ProductSubcategoryID
SELECT pc.Name, p.Name
FROM Production.ProductCategory pc 
FULL OUTER JOIN Production.Product p 
    ON p.ProductSubcategoryID = pc.ProductCategoryID;


--? SEMI and ANTI_SEMI
--! PhysicalOp="Nested Loops" LogicalOp="Left Semi Join"
SELECT *
FROM Sales.Customer c 
WHERE c.TerritoryID = 3 AND EXISTS (
    SELECT 1 
    FROM Sales.SalesOrderHeader h 
    WHERE c.CustomerID = h.CustomerID
);

--! PhysicalOp="Nested Loops" LogicalOp="Left Anti Semi Join"
SELECT *
FROM Sales.Customer c 
WHERE c.TerritoryID = 3 AND NOT EXISTS (
    SELECT 1 
    FROM Sales.SalesOrderHeader h 
    WHERE c.CustomerID = h.CustomerID
);

--Same results using IN:
--! PhysicalOp="Nested Loops" LogicalOp="Left Semi Join"
SELECT *
FROM Sales.Customer c 
WHERE c.TerritoryID = 3 AND c.CustomerID IN (
    SELECT CustomerID
    FROM Sales.SalesOrderHeader
);

--! PhysicalOp="Nested Loops" LogicalOp="Left Anti Semi Join"
SELECT *
FROM Sales.Customer c 
WHERE c.TerritoryID = 3 AND c.CustomerID NOT IN (
    SELECT CustomerID
    FROM Sales.SalesOrderHeader
);


--? APPLY
-- Basicaly 
-- CROSS APPLY = INNER JOIN
-- OUTER APPLY = LEFT OUTER JOIN
--! Nested Loops(Inner Join, OUTER REFERENCES:([p].[BusinessEntityID]))
SELECT top 50 p.FirstName, p.LastName, c.JobTitle
FROM Person.Person p 
CROSS APPLY dbo.ufnGetContactInformation(p.BusinessEntityID) c;

--! Nested Loops(Left Outer Join, OUTER REFERENCES:([p].[BusinessEntityID]))
SELECT top 50 p.FirstName, p.LastName, c.JobTitle
FROM Person.Person p 
OUTER APPLY dbo.ufnGetContactInformation(p.BusinessEntityID) c;

SET STATISTICS PROFILE OFF;
SET STATISTICS XML OFF;