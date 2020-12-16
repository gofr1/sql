USE [master];

-- FULL mode 
--! Requires log backups.
-- No work is lost due to a lost or damaged data file.
-- Can recover to an arbitrary point in time.

DROP DATABASE IF EXISTS TestFull;

CREATE DATABASE TestFull;
-- By default the recovery mode is FULL

USE TestFull;

CREATE TABLE dbo.Foo (
    Bar int
);

INSERT INTO dbo.Foo VALUES (1);

-- If you try to backup transaction log w/o having Full backup
BACKUP LOG TestFull TO DISK = N'/var/sqlbackup/TestFull.trn';
-- you will get error:
--* Msg 4214, Level 16, State 1, Line 1
--* BACKUP LOG cannot be performed because there is no current database backup. 

-- You can perform FULL backup
BACKUP DATABASE TestFull TO DISK = N'/var/sqlbackup/TestFull.bak';

INSERT INTO dbo.Foo VALUES (2);

-- Now let's perform txlog backup
BACKUP LOG TestFull TO DISK = N'/var/sqlbackup/TestFull1.trn';

INSERT INTO dbo.Foo VALUES (3);  --! In point-in-timw part this vaue will be missed

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1
--* 2
--* 3

-- Now let's perform txlog backup
BACKUP LOG TestFull TO DISK = N'/var/sqlbackup/TestFull2.trn';

USE [master];

-- Now restoring Full
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull.bak' WITH REPLACE;

USE TestFull;

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1 

USE [master];
-- Full
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull.bak' WITH REPLACE, NORECOVERY;
-- Tran log 1
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull1.trn' WITH RECOVERY;

USE TestFull;

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1
--* 2

USE [master];
-- Full
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull.bak' WITH REPLACE, NORECOVERY;
-- Tran log 1
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull1.trn' WITH NORECOVERY;
-- Tran log 2
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull2.trn' WITH RECOVERY;

USE TestFull;

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1
--* 2
--* 3

USE [master];
-- Full
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull.bak' WITH REPLACE, NORECOVERY;
-- Tran log 1
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull1.trn' WITH NORECOVERY;
-- Tran log 2 with point-in-time
RESTORE DATABASE TestFull
FROM DISK = N'/var/sqlbackup/TestFull2.trn' WITH STOPAT = N'2020-10-26 13:32:55', RECOVERY;

-- if the STOPAT time is outside the range of times in the log backup
-- you will need to restore db like this:
RESTORE DATABASE TestFull WITH RECOVERY;

USE TestFull;

SELECT Bar FROM dbo.Foo;
--* Bar
--* 1
--* 2