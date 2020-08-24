USE DEMO;
GO

DROP TRIGGER IF EXISTS dbo.TableWithTriggerModify;
DROP TABLE IF EXISTS dbo.TableWithTrigger;

CREATE TABLE dbo.TableWithTrigger (
    Id int IDENTITY(1,1) NOT NULL,
    EmailId int NOT NULL,
    Comments varchar(1000),
    CONSTRAINT [PK_TableWithTrigger_Id] PRIMARY KEY CLUSTERED (Id)
);
GO

CREATE OR ALTER TRIGGER dbo.TableWithTriggerModify ON dbo.TableWithTrigger  
FOR INSERT 
AS  
IF (ROWCOUNT_BIG() = 0)
RETURN;
IF EXISTS (
    SELECT *  
    FROM inserted i 
    LEFT JOIN dbo.Emails e 
        ON e.Id = i.EmailId
    WHERE e.Id IS NULL
)  
BEGIN  
RAISERROR ('There are no such email addresses in Emails table', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO  

--That insert should go fine
INSERT INTO dbo.TableWithTrigger (EmailId, Comments) VALUES
(1, 'Some random comment');

SELECT *
FROM dbo.TableWithTrigger;

--That should fire a trigger
INSERT INTO dbo.TableWithTrigger (EmailId, Comments) VALUES
(5, 'One more random comment');

--Let's try update
UPDATE dbo.TableWithTrigger
SET EmailId = 5
WHERE Id = 1

--It will update the value 
SELECT *
FROM dbo.TableWithTrigger;

--Revert changes
UPDATE dbo.TableWithTrigger
SET EmailId = 1
WHERE Id = 1
GO

--Let's modify trigger to look for updates
CREATE OR ALTER TRIGGER dbo.TableWithTriggerModify ON dbo.TableWithTrigger  
FOR INSERT, UPDATE
AS  
IF (ROWCOUNT_BIG() = 0)
RETURN;
IF EXISTS (
    SELECT *  
    FROM inserted i 
    LEFT JOIN dbo.Emails e 
        ON e.Id = i.EmailId
    WHERE e.Id IS NULL
)  
BEGIN  
RAISERROR ('There are no such email addresses in Emails table', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO  

--Let's try update one more time
UPDATE dbo.TableWithTrigger
SET EmailId = 5
WHERE Id = 1

--It will NOT update the value 
SELECT *
FROM dbo.TableWithTrigger;

DROP TRIGGER IF EXISTS dbo.TableWithTriggerModify;
DROP TABLE IF EXISTS dbo.TableWithTrigger;
