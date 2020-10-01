
USE [master];
--Creating of the snapshot
DROP DATABASE IF EXISTS AdventureWorksDW2012_snapshot;

CREATE DATABASE AdventureWorksDW2012_snapshot ON (
    NAME = AdventureWorksDW2012, 
    FILENAME = '/var/opt/mssql/data/AdventureWorksDW2012_snapshot.ss'
)
AS SNAPSHOT OF AdventureWorksDW2012;  

--Some modifications
USE AdventureWorksDW2012;

DROP TABLE dbo.FactFinance;

INSERT INTO dbo.DimCurrency VALUES (N'ZZZ', N'Zzzzz...');

SELECT * FROM dbo.DimCurrency WHERE CurrencyName = N'Zzzzz...'

--Restoring database from snapshot
USE [master];

ALTER DATABASE AdventureWorksDW2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE AdventureWorksDW2012 FROM DATABASE_SNAPSHOT = 'AdventureWorksDW2012_snapshot';

ALTER DATABASE AdventureWorksDW2012 SET MULTI_USER;

--Check if differences that were introduced earlier still persist
USE AdventureWorksDW2012;

SELECT COUNT(*) FROM dbo.FactFinance; --*39409

SELECT * FROM dbo.DimCurrency WHERE CurrencyName = N'Zzzzz...' --*Nothing

--!To restore (revert) the database from snapshot:

--!1. Only one snapshot can be use to restored. we have to drop all other snapshot first.
--!2. Only can be restore to the source database, we can not restore the snapshot to the different database.
--!3. If the source database contain FILESTREAM file group, the file group will be marked offline in the snapshot. 
--!The snapshot can not be used to revert it to the source database.

