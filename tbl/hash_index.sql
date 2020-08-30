USE DEMO;

DROP TABLE IF EXISTS dbo.HashTest;

CREATE TABLE dbo.HashTest (
    Id INTEGER NOT NULL IDENTITY(1,1),
    [Name] VARCHAR(50),
    CreationDate datetime NOT NULL,
    CONSTRAINT [PK_HashTest_Id] PRIMARY KEY NONCLUSTERED (Id)
)
WITH (
    MEMORY_OPTIMIZED = ON, 
    DURABILITY = SCHEMA_AND_DATA
);

--UNIQUE, or can default to Non-Unique.
--NONCLUSTERED, which is the default.
ALTER TABLE dbo.HashTest 
ADD INDEX HI_Name
HASH ([Name]) WITH (BUCKET_COUNT = 26); 
--The maximum number of buckets in hash indexes is 1,073,741,824.
--Usually bucket count = distinct values count

ALTER TABLE dbo.HashTest
ADD CONSTRAINT [DI_HashTest_CreationDate] DEFAULT CURRENT_TIMESTAMP FOR CreationDate;

INSERT INTO dbo.HashTest ([Name]) VALUES 
('a'),('b'),('c');

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT * 
FROM dbo.HashTest;

INSERT INTO dbo.HashTest ([Name]) VALUES 
('alpha'),('betta');

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
GO
SET SHOWPLAN_TEXT ON 
GO
SELECT * FROM dbo.HashTest
WHERE Name like 'a%'
GO
SET SHOWPLAN_TEXT OFF 
GO