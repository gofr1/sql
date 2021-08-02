USE DEMO 
GO 

DROP TABLE IF EXISTS dbo.TestingNestedTran
GO

CREATE TABLE dbo.TestingNestedTran (Id INT)
GO

--? When used in nested transactions, commits of the inner transactions don't free resources or make their modifications permanent. 
--? The data modifications are made permanent and resources freed only when the outer transaction is committed.

--! First example
--! All INSERT statements will be commited
BEGIN TRAN T1
INSERT dbo.TestingNestedTran SELECT 1

BEGIN TRAN T2
INSERT dbo.TestingNestedTran SELECT 2

BEGIN TRAN T3
INSERT dbo.TestingNestedTran SELECT 3

ROLLBACK TRAN T3
ROLLBACK TRAN T2
COMMIT TRAN T1

SELECT Id
FROM dbo.TestingNestedTran

--* Id 
--* 1
--* 2
--* 3

TRUNCATE TABLE dbo.TestingNestedTran
GO 

--! Second example
--! All will be rollbacked

BEGIN TRAN T1
INSERT dbo.TestingNestedTran SELECT 1

BEGIN TRAN T2
INSERT dbo.TestingNestedTran SELECT 2

BEGIN TRAN T3
INSERT dbo.TestingNestedTran SELECT 3

COMMIT TRAN T3
COMMIT TRAN T2
ROLLBACK TRAN T1

SELECT Id
FROM dbo.TestingNestedTran

--* Id

TRUNCATE TABLE dbo.TestingNestedTran
GO 