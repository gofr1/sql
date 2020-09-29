USE [master];

DROP DATABASE IF EXISTS SSIsoTest;

CREATE DATABASE SSIsoTest;

ALTER DATABASE SSIsoTest SET RECOVERY SIMPLE;

--Snapshot isolation must be enabled by setting the ALLOW_SNAPSHOT_ISOLATION ON database 
--option before it is used in transactions. This activates the mechanism for storing row 
--versions in the temporary database (tempdb). 
ALTER DATABASE SSIsoTest SET ALLOW_SNAPSHOT_ISOLATION ON;

ALTER DATABASE SSIsoTest SET READ_COMMITTED_SNAPSHOT ON;

USE SSIsoTest;

DROP TABLE IF EXISTS dbo.TestSnapshot;

CREATE TABLE dbo.TestSnapshot (
    ID int primary key, 
    valueCol int
);

INSERT INTO TestSnapshot VALUES (1,1);

--Update statement from start_trun.sql will not block this select
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM dbo.TestSnapshot;


USE [master];
ALTER DATABASE SSIsoTest SET READ_COMMITTED_SNAPSHOT OFF;
--Now if we open transaction we could not read data from table