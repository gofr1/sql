USE [master];

CREATE DATABASE [SynonymTest];

ALTER DATABASE [SynonymTest] SET RECOVERY SIMPLE; 

USE SynonymTest;

DROP TABLE IF EXISTS dbo.SourceDB;

CREATE TABLE dbo.SourceDB (
    DBName sysname NOT NULL
);

INSERT INTO dbo.SourceDB (DBName) VALUES ('DEMO');

DROP TRIGGER IF EXISTS dbo.OneRowCheck;
GO

CREATE OR ALTER TRIGGER dbo.OneRowCheck ON dbo.SourceDB
INSTEAD OF INSERT, DELETE
AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
RAISERROR ('There can be only one row!', 16, 1);
GO

DELETE FROM dbo.SourceDB;

INSERT INTO dbo.SourceDB (DBName) VALUES ('SomeName');

SELECT DBName
FROM dbo.SourceDB;

--Create few synonyms
DROP SYNONYM IF EXISTS dbo.sEmployee;
DROP SYNONYM IF EXISTS dbo.sDepartment;

CREATE SYNONYM dbo.sEmployee
FOR DEMO.dbo.Employee;

CREATE SYNONYM dbo.sDepartment
FOR DEMO.dbo.Department;

--Some info about synonyms
SELECT OBJECTPROPERTYEX(OBJECT_ID('sEmployee'), 'BaseType') AS BaseType;  
SELECT * FROM sys.synonyms;

--Lets create a SP that will change synonyms based on 
--DB from SourceDB table
DROP PROCEDURE IF EXISTS dbo.ChangeSynonymsDB
GO

CREATE OR ALTER PROCEDURE dbo.ChangeSynonymsDB
    @OldDBName sysname
AS
BEGIN 
    DECLARE @DBName sysname,
            @tsql NVARCHAR(max) = N'';

    SELECT @DBName = QUOTENAME(DBName) FROM dbo.SourceDB;
    SELECT @OldDBName = QUOTENAME(@OldDBName);
 
    SELECT @tsql = CONCAT(@tsql,'DROP SYNONYM ', sc.[name], '.', sy.[name],
           '; CREATE SYNONYM ', sc.[name], '.', sy.[name], ' FOR ', REPLACE(sy.base_object_name,@OldDBName,@DBName), ';', CHAR(10))
    FROM sys.synonyms sy 
    INNER JOIN sys.schemas sc 
        ON sc.schema_id = sy.schema_id
    WHERE LEFT(sy.[name],1) = 's';
    
    EXEC sp_executesql @tsql

END 
GO

--If value in SourceDB changes - we shall trigger our SP
CREATE OR ALTER TRIGGER dbo.IfUpdated ON dbo.SourceDB
AFTER UPDATE
AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
DECLARE @OldDBName sysname
SELECT @OldDBName = DBName FROM deleted
EXEC dbo.ChangeSynonymsDB @OldDBName;
GO

--Now we can use snapshot_create.sql to create a DB snapshot and try
-- to switch synonyms to the new source

--Check synonyms
SELECT [name], 
       [base_object_name]
FROM sys.synonyms;

--Change SourceDB
UPDATE dbo.SourceDB SET DBName = 'DEMO_snapshot';

--Check synonyms once again
SELECT [name], 
       [base_object_name]
FROM sys.synonyms;

--And DB name now changes from [DEMO] to [DEMO_snapshot]
-- Lets try to select from synonym

SELECT e.[Name],
       e.[Gender],
       e.[BirthDate],
       e.[Salary],
       d.[Name] as DeptName
FROM dbo.sEmployee e 
LEFT JOIN dbo.sDepartment d 
    ON e.DeptID = d.ID

--Now switch back the Source DB
UPDATE dbo.SourceDB SET DBName = 'DEMO';

--Check synonyms once again
SELECT [name], 
       [base_object_name]
FROM sys.synonyms;
--They points to [DEMO] database

--Don't forget to drop snapshot