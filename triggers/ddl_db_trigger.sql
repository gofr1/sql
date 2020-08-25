USE DEMO;
GO

DROP TABLE IF EXISTS dbo.TestDropAlterTrigger;

DROP TRIGGER IF EXISTS [safety];
GO

CREATE OR ALTER TRIGGER [safety]   
ON DATABASE   
FOR DROP_TABLE, ALTER_TABLE   
AS   
    PRINT 'You must disable Trigger "safety" to drop or alter tables!'   
    ROLLBACK;
GO

SELECT *
FROM sys.triggers;

--Let's try to drop some table
CREATE TABLE dbo.TestDropAlterTrigger (
    id int not null,
    info varchar(500) null
);

DROP TABLE dbo.TestDropAlterTrigger;
--We will get message: 
--You must disable Trigger "safety" to drop or alter tables!
--Msg 3609, Level 16, State 2, Line 2
--The transaction ended in the trigger. The batch has been aborted. 

--Let's disable trigger (and drop it further)
DISABLE TRIGGER [safety] -- ALL 
ON DATABASE;--object_name | DATABASE | ALL SERVER

--Now the table will be droped
DROP TABLE IF EXISTS dbo.TestDropAlterTrigger;

--Check that trigger is disabled
SELECT [name],
       is_disabled --  will show 1
FROM sys.triggers;

DROP TRIGGER [safety] ON DATABASE;