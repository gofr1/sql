USE [master];

--Check cureent database and sql server version
SELECT DB_NAME() [db],
       CURRENT_TIMESTAMP [current_time],
       @@VERSION [sql_version];

--Get database files location and size 
SELECT db.name AS DBName,
       mf.name as [FileName],
       mf.type_desc AS FileType,
       mf.physical_name AS LocationOfFiles,
       mf.[size] * 8.0 / 1024 as FileSizeMB
FROM sys.master_files mf
INNER JOIN sys.databases db 
    ON db.database_id = mf.database_id;

--Check current state of max server memory
SELECT *
FROM sys.configurations c 
WHERE c.[name] = 'max server memory (MB)';

--Get a list of databases with some options
SELECT database_id,
       [name] as [database_name],
       state_desc as current_state,
       page_verify_option_desc,
       recovery_model_desc,
       snapshot_isolation_state_desc,
       CASE WHEN is_read_committed_snapshot_on = 0 THEN 'OFF' ELSE 'ON' END is_read_committed_snapshot_on,
       [compatibility_level],
       CASE [compatibility_level]  
           WHEN 70 THEN '7.0 through 2008'
           WHEN 80 THEN '2000 (8.x) through 2008 R2'
           WHEN 90 THEN '2008 through 2012 (11.x)'
           WHEN 100 THEN '2008'
           WHEN 110 THEN '2012 (11.x)'
           WHEN 120 THEN '2014 (12.x)'
           WHEN 130 THEN '2016 (13.x)'
           WHEN 140 THEN '2017 (14.x)'
           WHEN 150 THEN '2019 (15.x)' END as compatibility_level_desc,
       collation_name
FROM sys.databases;

-- Check if Full-Text Search is installed
SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') IsFullTextInstalled;

--Get data about machine on which sql server is running
SELECT *
FROM sys.dm_os_host_info;

--Returns a miscellaneous set of useful information about the computer, 
--and about the resources available to and consumed by SQL Server.
SELECT *
FROM sys.dm_os_sys_info;

--Get property information about the server instance.
SELECT SERVERPROPERTY('Collation') Collation,
       SERVERPROPERTY('Edition') [Edition],
       SERVERPROPERTY('InstanceName') InstanceName,
       SERVERPROPERTY('IsFullTextInstalled') IsFullTextInstalled,
       SERVERPROPERTY('IsPolyBaseInstalled') IsPolyBaseInstalled,
       SERVERPROPERTY('LicenseType') LicenseType,
       SERVERPROPERTY('ProductUpdateLevel') ProductUpdateLevel,
       SERVERPROPERTY('SqlSortOrderName') SqlSortOrderName;
  
SELECT *  
FROM sys.database_scoped_configurations;