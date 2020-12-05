USE [master];

CREATE DATABASE DetachDB;

USE DetachDB;

CREATE TABLE dbo.Sample (
    nm nvarchar(10) not null
);

INSERT INTO dbo.Sample VALUES ('OK');

USE [master];

SELECT db.name AS DBName,
       mf.physical_name AS LocationOfFiles
FROM sys.master_files mf
INNER JOIN sys.databases db 
    ON db.database_id = mf.database_id
WHERE db.[name] = N'DetachDB';
--* DetachDB /var/opt/mssql/data/DetachDB.mdf

EXEC sp_detach_db 'DetachDB', 'true'; 

SELECT [name]
FROM sys.databases
WHERE [name] = N'DetachDB';
--* Nothing

CREATE DATABASE AttachDB   
ON (FILENAME = '/var/opt/mssql/data/DetachDB.mdf'),   
(FILENAME = '/var/opt/mssql/data/DetachDB_log.ldf')   
FOR ATTACH;

SELECT db.name AS DBName,
       mf.physical_name AS LocationOfFiles
FROM sys.master_files mf
INNER JOIN sys.databases db 
    ON db.database_id = mf.database_id;

--* DBName    LocationOfFiles
--* AttachDB  /var/opt/mssql/data/DetachDB.mdf
--* AttachDB  /var/opt/mssql/data/DetachDB_log.ldf

USE AttachDB;

SELECT *
FROM dbo.Sample;