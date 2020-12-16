USE [master];

-- BULK_LOGGED mode 
--! Requires log backups.
-- Can recover to the end of any backup. 
--! Point-in-time recovery is not supported.
-- If the log is damaged or bulk-logged operations occurred since the most recent log backup, 
-- changes since that last backup must be redone.

-- With this model there are certain bulk operations such as BULK INSERT, CREATE INDEX, SELECT INTO, etc... 
-- that are not fully logged in the transaction log and therefore do not take as much space in the transaction log. 

DROP DATABASE IF EXISTS TestBulkLogged;

CREATE DATABASE TestBulkLogged;
-- By default the recovery mode is FULL so we will change recovery model before and after bulk operations

USE TestBulkLogged;

DROP TABLE IF EXISTS dbo.BulkLoad;
 
CREATE TABLE dbo.BulkLoad (
    PersonID INT,
    FullName VARCHAR(512),
    PreferredName VARCHAR(512),
    SearchName VARCHAR(512),
    IsPermittedToLogon BIT,
    LogonName VARCHAR(512)
);

BACKUP DATABASE TestBulkLogged TO DISK = N'/var/sqlbackup/TestBulkLogged.bak';

BULK INSERT dbo.BulkLoad
FROM '/var/opt/mssql/load/test_CSV_File.txt'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n' --for windows it is usually \r\n
); 

BACKUP LOG TestBulkLogged TO DISK = N'/var/sqlbackup/TestBulkLogged.trn';

USE [master];

RESTORE DATABASE TestBulkLogged
FROM DISK = N'/var/sqlbackup/TestBulkLogged.bak' WITH REPLACE;

ALTER DATABASE TestBulkLogged SET RECOVERY BULK_LOGGED;

USE TestBulkLogged;

BULK INSERT dbo.BulkLoad
FROM '/var/opt/mssql/load/test_CSV_File.txt'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n' --for windows it is usually \r\n
); 

ALTER DATABASE TestBulkLogged SET RECOVERY FULL;

BACKUP LOG TestBulkLogged TO DISK = N'/var/sqlbackup/TestBulkLoggedOn.trn';

--Now lets check the size of transaction log
--* ls -lah /var/sqlbackup/TestB*
--* 3.0M /var/sqlbackup/TestBulkLogged.bak
--? 300K /var/sqlbackup/TestBulkLoggedOn.trn
--! 108K /var/sqlbackup/TestBulkLogged.trn

--Let's chack the data
-- At first resore from first transaction log
USE [master];
-- Full
RESTORE DATABASE TestBulkLogged
FROM DISK = N'/var/sqlbackup/TestBulkLogged.bak' WITH REPLACE, NORECOVERY;
-- Tran log
RESTORE DATABASE TestBulkLogged
FROM DISK = N'/var/sqlbackup/TestBulkLogged.trn' WITH RECOVERY;

USE TestBulkLogged;

SELECT * FROM dbo.BulkLoad; --5 rows

-- Then we restore from another tran log
USE [master];
-- Full
RESTORE DATABASE TestBulkLogged
FROM DISK = N'/var/sqlbackup/TestBulkLogged.bak' WITH REPLACE, NORECOVERY;
-- Tran log
RESTORE DATABASE TestBulkLogged
FROM DISK = N'/var/sqlbackup/TestBulkLoggedOn.trn' WITH RECOVERY;

USE TestBulkLogged;

SELECT * FROM dbo.BulkLoad; -- same 5 rows
