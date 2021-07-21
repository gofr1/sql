USE [AdventureWorks2012]
GO
--!  _  - Match One Character
--! [ ] - Character(s) to Match [as] [0-9a-z] etc. 
--! [^] - Character(s) Not to Match [^as] [^0-9a-z]

-- Check DB's collation
SELECT  [NAME], 
        COLLATION_NAME
FROM sys.databases
WHERE DATABASE_ID = DB_ID(DB_NAME())
GO
-- SQL_Latin1_General_CP1_CI_AS
-- Case insensitive so no matter if use D or d in search

DROP TABLE IF EXISTS #person_like_test
GO
-- Prepare table to work with
WITH person_ AS (
SELECT p.BusinessEntityID,
       p.FirstName,
       p.LastName, 
       a.City,
       a.PostalCode,
       a.AddressLine1 as AddressLine,
       ROW_NUMBER() OVER (PARTITION BY p.LastName ORDER BY a.PostalCode) as rn,
       ROW_NUMBER() OVER (PARTITION BY a.City ORDER BY a.PostalCode) as rn1,
       ROW_NUMBER() OVER (PARTITION BY p.FirstName ORDER BY a.PostalCode) as rn2
FROM Person.Person p 
INNER JOIN Person.BusinessEntityAddress bea 
    ON p.BusinessEntityID = bea.BusinessEntityID
INNER JOIN Person.Address a 
    ON a.AddressID = bea.BusinessEntityID
)

SELECT BusinessEntityID,
       FirstName,
       LastName, 
       City,
       PostalCode,
       AddressLine
INTO #person_like_test
FROM person_
WHERE rn = rn1 and rn1 = rn2
GO

--34 rows, that's good
SELECT * 
FROM #person_like_test
GO

-- Get all Employees from the City that starts with O or M
SELECT *
FROM #person_like_test
WHERE City LIKE '[om]%'
ORDER BY City

-- Get all Employees from the City that starts with B, C or D
SELECT *
FROM #person_like_test
WHERE City LIKE '[b-d]%'
ORDER BY City

-- Get all Employees from the City that starts with not O or M
SELECT *
FROM #person_like_test
WHERE City LIKE '[^om]%' -- same is WHERE City NOT LIKE '[om]%'
ORDER BY City

-- Get all Employees from the City that starts with not B, C or D
SELECT *
FROM #person_like_test
WHERE City LIKE '[^b-d]%' -- same is WHERE City NOT LIKE '[b-d]%'
ORDER BY City

-- Get all employees who have addresses with a four-digit postal code
SELECT *
FROM #person_like_test
WHERE PostalCode LIKE '[0-9][0-9][0-9][0-9]'

-- Starts with two digits ans special symbol
SELECT *
FROM #person_like_test
WHERE AddressLine LIKE '[0-9][0-9][!@#$.,;_]%';

-- Find all databases that starts with M, the secobd char is any from A to O, the third char is D
SELECT [name] 
FROM sys.databases
WHERE [name] LIKE 'm[a-o]d%';

-- Return all DB's principals that starts with 'db_'
SELECT [name] 
FROM sys.database_principals
WHERE [name] LIKE 'db[_]%';

-- And this returns all DB's principals that starts with db and any other char
SELECT [name] 
FROM sys.database_principals
WHERE [name] LIKE 'db_%';
-- Results will include 'dbo'