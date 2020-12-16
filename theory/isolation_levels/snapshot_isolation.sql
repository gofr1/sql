USE [master];
--At first let's enable Snapshot Isolation on database
ALTER DATABASE DEMO SET ALLOW_SNAPSHOT_ISOLATION ON;

USE DEMO;
--Set isolation level to SNAPSHOT
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRANSACTION;
-- Selected value will be:
--*Id   Email
--*3    email@example.com

SELECT *
FROM dbo.Emails
WHERE Id = 3;

--During this delay let's run an update query from start_tran.sql
WAITFOR DELAY '00:00:10';

--Evan we changed the data we will get same results:
--*Id   Email
--*3    email@example.com

SELECT *
FROM dbo.Emails
WHERE Id = 3;

--And this update will failed
UPDATE dbo.Emails
SET Email = 'AHA@example.com'
WHERE Id = 3;
--!Msg 3960, Level 16, State 2, Line 18
--!Snapshot isolation transaction aborted due to update conflict. 
--!You cannot use snapshot isolation to access table 'dbo.Emails' directly or indirectly 
--!in database 'DEMO' to update, delete, or insert the row that has been modified or 
--!deleted by another transaction. Retry the transaction or change the isolation level 
--!for the update/delete statement. 

COMMIT TRANSACTION;

SELECT *
FROM dbo.Emails
WHERE Id = 3;
--In a table there will be new value:
--*Id   Email
--*3    address@example.com
