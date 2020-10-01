--Prior to SQL Server 2019, these versions were stored in tempdb. 
--SQL Server 2019 introduces a new feature, Accelerated Database Recovery (ADR) which requires 
--its own set of row versions. So, as of SQL Server 2019, if ADR is not enabled, row versions 
--are kept in tempdb as always. 
--If ADR is enabled, then all row versions, both related to snapshot isolation and ADR, are kept 
--in ADR's Persistent Version Store (PVS), which is located in the user database in a filegroup 
--which the user specifies. 

USE [master];

DROP DATABASE IF EXISTS SSIsoTest;

CREATE DATABASE SSIsoTest;

ALTER DATABASE SSIsoTest SET RECOVERY SIMPLE;

--Snapshot isolation must be enabled by setting the ALLOW_SNAPSHOT_ISOLATION ON database 
--option before it is used in transactions. This activates the mechanism for storing row 
--versions in the temporary database (tempdb). 
ALTER DATABASE SSIsoTest SET ALLOW_SNAPSHOT_ISOLATION ON;

ALTER DATABASE SSIsoTest SET READ_COMMITTED_SNAPSHOT ON;
--Modified rows will be stored in Version Store in tempdb (or in memory if certain features are enabled)

USE SSIsoTest;

DROP TABLE IF EXISTS dbo.TestSnapshot;

CREATE TABLE dbo.TestSnapshot (
    ID int primary key, 
    valueCol int
);

INSERT INTO TestSnapshot VALUES (1,1);

--Update statement from start_tran.sql will not block this select
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM dbo.TestSnapshot;


USE [master];
ALTER DATABASE SSIsoTest SET READ_COMMITTED_SNAPSHOT OFF;
--Now if we open transaction we could not read data from table