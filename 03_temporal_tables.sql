USE DEMO
GO

CREATE TABLE dbo.TestWithHistory (
    Id int IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    [Name] varchar(50) NOT NULL,
    CreationDate datetime2(2) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidFrom DATETIME2(2) GENERATED ALWAYS AS ROW START,
    ValidTo DATETIME2(2) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON)
GO

INSERT INTO dbo.TestWithHistory (Name)
VALUES ('Value0'),('Value1'),('Value3'),('Value4')

SELECT *
FROM dbo.TestWithHistory

DELETE FROM dbo.TestWithHistory WHERE Id = 4

--SELECT * FROM sys.tables

SELECT *  -- 4 rows
FROM dbo.TestWithHistory
FOR SYSTEM_TIME AS OF '2019-11-16 15:21:00'
WHERE 1=1


SELECT * -- no rows
FROM dbo.TestWithHistory
FOR SYSTEM_TIME AS OF '2019-11-16'
WHERE 1=1