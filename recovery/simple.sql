USE [master];

-- SIMPLE mode 
-- No log backups. No Point-in-Time recovery.
-- Changes since the most recent backup are unprotected. 
-- In the event of a disaster, those changes must be redone.
-- Can recover only to the end of a backup (Full or Differential)

DROP DATABASE IF EXISTS TestSimple;

CREATE DATABASE TestSimple;

-- By default the recovery mode is FULL, so let's change to simple
ALTER DATABASE TestSimple SET RECOVERY SIMPLE; 

USE TestSimple;

CREATE TABLE dbo.Foo (
    Bar int
);

INSERT INTO dbo.Foo VALUES (1);

-- If you try to backup transaction log 
BACKUP LOG TestSimple TO DISK = N'/var/sqlbackup/TestSimple.trn';
-- you will get error:
--* Msg 4208, Level 16, State 1, Line 1
--* The statement BACKUP LOG is not allowed while the recovery model is SIMPLE. 
--* Use BACKUP DATABASE or change the recovery model using ALTER DATABASE. 
-- because SIMPLE mode doesn't support log backup

-- You can perform FULL backup
BACKUP DATABASE TestSimple TO DISK = N'/var/sqlbackup/TestSimple.bak' WITH INIT;

INSERT INTO dbo.Foo VALUES (2);

-- Or deifferential backup
BACKUP DATABASE TestSimple  
TO DISK = N'/var/sqlbackup/TestSimple1.dif'
WITH DIFFERENTIAL;  

INSERT INTO dbo.Foo VALUES (3); --! that record would be lost

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1
--* 2
--* 3

USE [master];

-- Now restoring Full
RESTORE DATABASE TestSimple
FROM DISK = N'/var/sqlbackup/TestSimple.bak';

USE TestSimple;

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1 

USE [master];
-- Full
RESTORE DATABASE TestSimple
FROM DISK = N'/var/sqlbackup/TestSimple.bak' WITH NORECOVERY;
-- Diff
RESTORE DATABASE TestSimple
FROM DISK = N'/var/sqlbackup/TestSimple1.dif' WITH RECOVERY;

USE TestSimple;

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1
--* 2