USE DEMO;

BEGIN TRANSACTION;

UPDATE dbo.DL2
SET id = 1;

WAITFOR DELAY '00:00:08';

UPDATE dbo.DL1 
SET id = 1;

COMMIT TRANSACTION;
--Hera we will get:
--!Transaction (Process ID 166) was deadlocked on lock resources with another 
--!process and has been chosen as the deadlock victim. Rerun the transaction. 