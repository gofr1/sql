USE [master];

DROP DATABASE IF EXISTS RoundRobin;

CREATE DATABASE RoundRobin ON PRIMARY (
    NAME = 'RoundRobin',
    FILENAME = '/var/opt/mssql/data/roundrobin.mdf',
    SIZE = 5MB,
    MAXSIZE = 4096MB,
    FILEGROWTH = 1024KB
), --Secondary File group
FILEGROUP FileGroup0 ( 
    NAME = 'RoundRobin0',--First file
    FILENAME = '/var/opt/mssql/data/FileGroup0.ndf',
    SIZE = 5MB,
    MAXSIZE = 4096MB,
    FILEGROWTH = 1024KB   
), (
    NAME = 'RoundRobin1', --Second file
    FILENAME = '/var/opt/mssql/data/FileGroup1.ndf',
    SIZE = 5MB,
    MAXSIZE = 4096MB,
    FILEGROWTH = 1024KB   
)
LOG ON (
    NAME = 'RoundRobin_log', --Log file
    FILENAME = '/var/opt/mssql/data/roundrobin_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 4096MB,
    FILEGROWTH = 1024KB      
);

--Change default file group so new objects will be created within it
ALTER DATABASE RoundRobin MODIFY FILEGROUP FileGroup0 DEFAULT;

--Checking the results
SELECT DB_NAME(mf.database_id) AS database_name,
       mf.[name] as [file_name],
       mf.[type_desc] AS file_type,
       mf.physical_name AS file_location,
       mf.[size] * 8.0 / 1024 as file_size_mb,
       fg.[name] as filegroup_name,
       fg.type_desc as filegroup_type,
       fg.is_default as is_filegroup_default
FROM sys.master_files mf 
LEFT JOIN sys.filegroups fg 
    ON fg.data_space_id = mf.data_space_id
WHERE DB_NAME(database_id) = 'RoundRobin';

USE RoundRobin;

DROP TABLE IF EXISTS dbo.TestRoundRobin;

CREATE TABLE dbo.TestRoundRobin (
    UsefulText VARCHAR(8000)
);

WITH cte AS (
    SELECT 1 as rn,
           REPLICATE('Some Very Very Useful Text Goes Here ', 222) as UsefulText
    UNION ALL 
    SELECT rn + 1,
           UsefulText
    FROM cte 
    WHERE rn < 40000
)

INSERT INTO dbo.TestRoundRobin (UsefulText)
SELECT UsefulText 
FROM cte 
OPTION (MAXRECURSION 0);

--We can check in terminal that files are growing simultaneously
--*ls -lah  /var/opt/mssql/data/ | grep FileGroup

--Here we can check how files are filled
SELECT df.type_desc,
       df.physical_name,
       vf.*
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) vf -- Returns I/O statistics for data and log files
INNER JOIN sys.database_files df 
    ON df.file_id = vf.file_id

--!Better approach is to use different physical drives to get performance in IO operations.