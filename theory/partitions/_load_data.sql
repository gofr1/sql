USE DEMO;

DROP TABLE IF EXISTS  dbo.IndexTestAddOn;

WITH cte AS (
    SELECT CONCAT(FirstName, ' ', LastName) as [Value]
    FROM AdventureWorks2017.Person.Person
    UNION ALL
    SELECT AddressLine1
    FROM AdventureWorks2017.Person.Address 
)

SELECT IDENTITY(int, 10001, 1) as Id,
       [Value]
INTO dbo.IndexTestAddOn
FROM cte;

SELECT MAX(Id) FROM dbo.IndexTest;

INSERT INTO dbo.IndexTest
SELECT *
FROM dbo.IndexTestAddOn
WHERE Id BETWEEN 20001 and 24568
ORDER BY Id DESC