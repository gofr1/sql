USE DEMO;

DROP VIEW IF EXISTS dbo.WLview;
GO

CREATE VIEW dbo.WLview 
AS
SELECT PersonId,
       StuffId
FROM dbo.Wishlist;
GO

CREATE OR ALTER TRIGGER dbo.WLviewModify ON dbo.WLview 
INSTEAD OF INSERT, UPDATE, DELETE -- You cannot user AFTER or FOR triggers with views
AS  
IF (ROWCOUNT_BIG() = 0)
RETURN;
RAISERROR ('You cannot use insert/update/delete on this view', 16, 1)
RETURN;
GO  
--Now we can not insert (or update delete)
INSERT INTO dbo.WLview (PersonId, StuffId) VALUES (2, 5);

--Now let's disable trigger
DISABLE TRIGGER dbo.WLviewModify ON dbo.WLview;

--Let's try to insert
INSERT INTO dbo.WLview (PersonId, StuffId) VALUES (2, 5);

SELECT *
FROM dbo.WLview;

SELECT * 
FROM dbo.Wishlist;

DELETE FROM dbo.WLview WHERE PersonId = 2 AND [StuffId] = 5;

DROP TRIGGER IF EXISTS dbo.WLviewModify;