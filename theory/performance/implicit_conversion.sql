-- Implicit conversion in SQL Server
USE DEMO;
GO

-- Some data 
DROP TABLE IF EXISTS dbo.TestPrecedence
 
CREATE TABLE dbo.TestPrecedence (
    NumericColumn INT
)
 
INSERT INTO dbo.TestPrecedence 
VALUES (1), (2), (3);

-- Example
SET STATISTICS PROFILE, XML ON;

SELECT * 
FROM dbo.TestPrecedence 
WHERE NumericColumn = N'1';

--*    <ScalarOperator ScalarString="[DEMO].[dbo].[TestPrecedence].[NumericColumn]=CONVERT_IMPLICIT(int,[@1],0)">
-- The query optimizer converts the textual data type to an integer because INT data type precedence is higher than NVARCHAR

SET STATISTICS PROFILE, XML OFF;

SELECT * 
FROM dbo.TestPrecedence 
WHERE NumericColumn = N'A';

--! Msg 245, Level 16, State 1, Line 1
--! Conversion failed when converting the nvarchar value 'A' to data type int. 

USE WideWorldImporters;
GO

SET STATISTICS PROFILE, XML ON;

SELECT TransactionDate,
       IsFinalized
FROM [Sales].[CustomerTransactions]
where IsFinalized LIKE '1%';

--! <Warnings>
--!   <PlanAffectingConvert ConvertIssue="Cardinality Estimate" Expression="CONVERT_IMPLICIT(varchar(1),[WideWorldImporters].[Sales].[CustomerTransactions].[IsFinalized],0)"></PlanAffectingConvert>
--!   <PlanAffectingConvert ConvertIssue="Seek Plan" Expression="CONVERT_IMPLICIT(varchar(1),[WideWorldImporters].[Sales].[CustomerTransactions].[IsFinalized],0)&gt;=&apos;1&apos;"></PlanAffectingConvert>
--! </Warnings>
-- Here we got 2 warnings

SET STATISTICS PROFILE, XML OFF;