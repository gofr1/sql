--! What is Parameter Sniffing in SQL Server?

-- Every batch you execute, either ad-hoc or stored procedure, generates a query plan that is kept in 
-- the plan cache for future usage. SQL Server attempts to create the best query plan to retrieve the data, 
-- but what may seem obvious is not always the case with the plan cache.

-- The way SQL Server choses the best plan is by cost estimation. For example, if I ask you which is best, 
-- an index seek followed by a key lookup or a table scan you may answer the first, but it depends on the 
-- number of lookups. In other words it depends on the amount of data being retrieved. 
-- So the best query plan takes into consideration the cardinality estimation based on input parameters 
-- and with the help of statistics.

-- When the optimizer creates an execution plan it sniffs the parameter values. 
-- This is not an issue; in fact it is needed to build the best plan. 
-- The problem arises when a query uses a previously generated plan optimized for a different data distribution.

-- In most cases the database workload is homogeneous so parameter sniffing won’t be a problem; 
-- but on a small number of cases this becomes a problem and the outcome can be dramatic.

USE DEMO;

DROP TABLE IF EXISTS dbo.ParamSniffHeader;
DROP TABLE IF EXISTS dbo.ParamSniffRows;

CREATE TABLE dbo.ParamSniffHeader (
    Id int NOT NULL IDENTITY(1,1),
    Header UNIQUEIDENTIFIER NOT NULL,
    Amount DECIMAL(15,8) NOT NULL,
    Category CHAR(1) NOT NULL,
    CONSTRAINT PK_ParamSniffHeader_Id PRIMARY KEY (Id ASC)
);

ALTER TABLE dbo.ParamSniffHeader  
ADD CONSTRAINT DF_ParamSniffHeaderCategory
DEFAULT 'A' FOR Category

CREATE TABLE dbo.ParamSniffRows (
    Id int NOT NULL IDENTITY(1,1),
    HeaderId INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Cost DECIMAL(15,8) NOT NULL,
    CONSTRAINT PK_ParamSniffRows_Id PRIMARY KEY (Id ASC)
);

INSERT INTO dbo.ParamSniffHeader (Header, Amount)
SELECT OrderId, SUM(CAST(Qty as int) * Price)
FROM dbo.BatchTest
GROUP BY OrderId;

INSERT INTO dbo.ParamSniffRows (HeaderId, ProductName, Cost)
SELECT h.Id, b.Product, b.Price * CAST(b.Qty as int)
FROM dbo.ParamSniffHeader h 
INNER JOIN dbo.BatchTest b 
    ON h.Header = b.OrderId;

UPDATE dbo.ParamSniffHeader
SET Category = CASE WHEN Amount >= 2000 THEN 'A' WHEN Amount between 1000 and 1999 THEN 'B' ELSE 'C' END

CREATE INDEX IX_ParamSniffHeader_Category
ON ParamSniffHeader(Category);

SELECT Category, COUNT(*)
FROM dbo.ParamSniffHeader
GROUP BY Category
ORDER BY Category

SET STATISTICS PROFILE ON;

SELECT *
FROM dbo.ParamSniffRows r 
INNER JOIN dbo.ParamSniffHeader h 
    ON h.Id = r.HeaderId
WHERE h.Category = 'A'

--DBCC FREEPROCCACHE();

SELECT *
FROM dbo.ParamSniffRows r 
INNER JOIN dbo.ParamSniffHeader h 
    ON h.Id = r.HeaderId
WHERE h.Category = 'C'

-- The plans are different. Let's create stored procedure:

DROP PROCEDURE IF EXISTS dbo.TestSniffing;
GO

CREATE PROCEDURE dbo.TestSniffing 
    @Category CHAR(1)
AS
BEGIN
    SELECT *
    FROM dbo.ParamSniffRows r 
    INNER JOIN dbo.ParamSniffHeader h 
        ON h.Id = r.HeaderId
    WHERE h.Category = @Category
END
GO

EXEC dbo.TestSniffing 'A';

EXEC dbo.TestSniffing 'C';

-- Both procedures has same query plan 

--*             PhysicalOp              LogicalOp
--* |--         Hash Match              Inner Join
--*    |--      Nested Loops            Inner Join
--*    |  |--   Index Seek              Index Seek
--*    |  |--   Clustered Index Seek    Clustered Index Seek
--*    |--      Clustered Index Scan    Clustered Index Scan

-- Clear cache and try another way

DBCC FREEPROCCACHE()

EXEC dbo.TestSniffing 'C';

EXEC dbo.TestSniffing 'A';
GO
-- Now the query plan is also the same bur differs from other
--* PhysicalOp            LogicalOp
--* |--    Hash Match            Inner Join
--*    |-- Clustered Index Scan  Clustered Index Scan
--*    |-- Clustered Index Scan  Clustered Index Scan

--! Workarounds for SQL Server Parameter Sniffing

--? Create SQL Server Stored Procedures using the WITH RECOMPILE Option
-- If the problem is that the optimizer uses a plan compiled with parameters that are no longer 
-- suitable then a recompilation will create a new plan with the new parameters right? \
-- This is the simplest solution, but not one of the best. If the problem is a single query inside 
-- the stored procedure code then performing a recompilation of the entire procedure is not the best approach. 

CREATE OR ALTER PROCEDURE dbo.TestSniffing 
    @Category CHAR(1)
WITH RECOMPILE
AS
BEGIN
    SELECT *
    FROM dbo.ParamSniffRows r 
    INNER JOIN dbo.ParamSniffHeader h 
        ON h.Id = r.HeaderId
    WHERE h.Category = @Category
END
GO

DBCC FREEPROCCACHE()

EXEC dbo.TestSniffing 'C';

EXEC dbo.TestSniffing 'A';
GO
-- The plans are different!

--? Use the SQL Server Hint OPTION (RECOMPILE)
-- Recompiling the whole stored procedure is not the best choice.  
-- We can take advantage of the hint RECOMPILE to recompile the awkward query alone. 

CREATE OR ALTER PROCEDURE dbo.TestSniffing 
    @Category CHAR(1)
AS
BEGIN
    SELECT *
    FROM dbo.ParamSniffRows r 
    INNER JOIN dbo.ParamSniffHeader h 
        ON h.Id = r.HeaderId
    WHERE h.Category = @Category
    OPTION (RECOMPILE)
END
GO

EXEC dbo.TestSniffing 'A';

EXEC dbo.TestSniffing 'C';
GO
-- The plans are different!

--? Use the SQL Server Hint OPTION (OPTIMIZE FOR)
-- This hint will allow us to set a parameter value to use as a reference for optimization.
-- The resulting plan will be something in between. So to use this hint you must consider 
-- how often the stored procedure is being executed with a wrong plan and how much it impacts 
-- your environment having a long running query.
CREATE OR ALTER PROCEDURE dbo.TestSniffing 
    @Category CHAR(1)
AS
BEGIN
    SELECT *
    FROM dbo.ParamSniffRows r 
    INNER JOIN dbo.ParamSniffHeader h 
        ON h.Id = r.HeaderId
    WHERE h.Category = @Category
    OPTION (OPTIMIZE FOR UNKNOWN) -- Or you can specify the value here
END
GO

EXEC dbo.TestSniffing 'A';

EXEC dbo.TestSniffing 'C';
GO

-- Same plans

--? Use Dummy Variables on SQL Server Stored Procedures (for SQL Server 2005)

CREATE OR ALTER PROCEDURE dbo.TestSniffing 
    @Category CHAR(1)
AS
BEGIN

    DECLARE @Dummy CHAR(1)
    
    SET @Dummy = @Category

    SELECT *
    FROM dbo.ParamSniffRows r 
    INNER JOIN dbo.ParamSniffHeader h 
        ON h.Id = r.HeaderId
    WHERE h.Category = @Category
    OPTION (OPTIMIZE FOR UNKNOWN) -- Or you can specify the value here
END
GO

EXEC dbo.TestSniffing 'A';

EXEC dbo.TestSniffing 'C';
GO
-- Same plans


--? Disable SQL Server Parameter Sniffing at the Instance Level (not recommended)
-- Parameter sniffing is not a bad thing per se and is very useful in most cases to get the best plan. 
-- But if you want, starting the instance with trace flag 4136 set will disable parameter sniffing.

--? Disable Parameter Sniffing for a Specific SQL Server Query

CREATE OR ALTER PROCEDURE dbo.TestSniffing 
    @Category CHAR(1)
AS
BEGIN
    SELECT *
    FROM dbo.ParamSniffRows r 
    INNER JOIN dbo.ParamSniffHeader h 
        ON h.Id = r.HeaderId
    WHERE h.Category = @Category
    OPTION (QUERYTRACEON 4136)
END
GO

EXEC dbo.TestSniffing 'A';

EXEC dbo.TestSniffing 'C';
GO

-- Same plans

SET STATISTICS PROFILE OFF;