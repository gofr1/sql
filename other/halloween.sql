USE DEMO;

--In computing, the Halloween Problem refers to a phenomenon in databases in which an update operation causes 
--a change in the physical location of a row, potentially allowing the row to be visited more than once during the operation.

--SQL Server uses Table Spool to manage this problem and separate Reading and Writting activities.

DROP TABLE IF EXISTS dbo.Halloween;

CREATE TABLE dbo.Halloween (
    id int PRIMARY KEY,
    SomeInteger int,
    OneMoreInteger int
);

CREATE NONCLUSTERED INDEX [IDX_Halloween_OneMoreInteger] ON dbo.Halloween (OneMoreInteger);

INSERT INTO dbo.Halloween VALUES (1, 1, 1), (2, 2, 2), (3, 3, 3);

SET STATISTICS XML ON;

UPDATE h
SET h.OneMoreInteger = OneMoreInteger * 2
FROM dbo.Halloween h WITH (INDEX(IDX_Halloween_OneMoreInteger))
WHERE h.OneMoreInteger < 3;

SET STATISTICS XML OFF;

--SQL Server introduces Table Spool here
--*<RelOp NodeId="5" PhysicalOp="Table Spool" LogicalOp="Eager Spool" ...

--If we use PROFILE instead of XML:
--*|--Clustered Index Update(OBJECT:([DEMO].[dbo].[Halloween].[PK__Hallowee__3213E83FCD4AC9DE] AS [h])..
--*     |--Compute Scalar(DEFINE:([Expr1005]=[Expr1005]))
--*          |--Compute Scalar(DEFINE:([Expr1005]=CASE WHEN [Expr1003] THEN (0) ELSE (1) END))
--*               |--Compute Scalar(DEFINE:([Expr1001]=[DEMO].[dbo].[Halloween].[OneMoreInteger] as [h].[OneMoreInteger]*(2) ..
--*                    |--Table Spool
--*                         |--Index Seek(OBJECT:([DEMO].[dbo].[Halloween].[IDX_Halloween_OneMoreInteger] ...

SELECT *
FROM dbo.Halloween;