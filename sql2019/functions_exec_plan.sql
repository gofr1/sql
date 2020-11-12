USE AdventureWorks2017;
GO
-- Compatibility level: 140 SQL Server 2017 (14.x)

CREATE OR ALTER FUNCTION dbo.SomeScalarFunction (
    @BusinessEntityID INT
)
RETURNS BIGINT
WITH RETURNS NULL ON NULL INPUT, SCHEMABINDING
AS
BEGIN
    DECLARE @BCount BIGINT;

    SELECT @BCount = COUNT_BIG(*)
    FROM Person.PersonPhone
    WHERE BusinessEntityID = @BusinessEntityID;

    RETURN @BCount;
END;
GO

SET STATISTICS PROFILE, TIME ON;

SELECT p.FirstName,
       p.LastName,
       dbo.SomeScalarFunction(p.BusinessEntityID) as PhoneCount
FROM Person.Person p

SET STATISTICS PROFILE, TIME OFF;

-- Not much info about what is going on in function
--* SELECT p.FirstName, p.LastName, dbo.SomeScalarFunction(p.BusinessEntityID) as PhoneCountFROM Person.Person p
--*   |--Compute Scalar(DEFINE:([Expr1001]=[AdventureWorks2017].[dbo].[SomeScalarFunction]([AdventureWorks2017].[Person].[Person].[BusinessEntityID] as [p].[BusinessEntityID])))
--*        |--Index Scan(OBJECT:([AdventureWorks2017].[Person].[Person].[IX_Person_LastName_FirstName_MiddleName] AS [p]))

--* SQL Server Execution Times:
--! CPU time = 1329 ms, elapsed time = 1386 ms. 

ALTER DATABASE AdventureWorks2017
SET COMPATIBILITY_LEVEL = 150;

-- After running above query now we can see much more details
--* SELECT p.FirstName, p.LastName, dbo.SomeScalarFunction(p.BusinessEntityID) as PhoneCountFROM Person.Person p
--*   |--Compute Scalar(DEFINE:([Expr1011]=CONVERT_IMPLICIT(bigint,CASE WHEN [AdventureWorks2017].[Person].[Person].[BusinessEntityID] as [p].[BusinessEntityID] IS NULL THEN NULL ELSE CASE WHEN [Expr1004]=(0) THEN NULL ELSE [Expr1005] END END,0)))
--*        |--Nested Loops(Inner Join, OUTER REFERENCES:([p].[BusinessEntityID]))
--*             |--Index Scan(OBJECT:([AdventureWorks2017].[Person].[Person].[IX_Person_LastName_FirstName_MiddleName] AS [p]))
--*             |--Nested Loops(Inner Join, PASSTHRU:([AdventureWorks2017].[Person].[Person].[BusinessEntityID] as [p].[BusinessEntityID] IS NULL))
--*                  |--Constant Scan
--*                  |--Compute Scalar(DEFINE:([Expr1004]=CONVERT_IMPLICIT(int,[Expr1016],0)))
--*                       |--Stream Aggregate(DEFINE:([Expr1016]=Count(*), [Expr1005]=ANY([Expr1003])))

--* SQL Server Execution Times:
--! CPU time = 178 ms, elapsed time = 192 ms.

-- Turn compatibility level back to 140
ALTER DATABASE AdventureWorks2017
SET COMPATIBILITY_LEVEL = 140;
