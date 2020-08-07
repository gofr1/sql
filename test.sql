--Check cureent database and sql server version
SELECT DB_NAME(),
       CURRENT_TIMESTAMP,
       @@VERSION;

--Get database files location and size 
SELECT db.name AS DBName,
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
SELECT database_id as Id,
       name as DBName,
       state_desc as CurrentState,
       page_verify_option_desc as PageOption,
       recovery_model_desc as RecoveryModel,
       snapshot_isolation_state_desc as SI,
       CASE WHEN is_read_committed_snapshot_on = 0 THEN 'OFF' ELSE 'ON' END RCSI
FROM sys.databases;

-- Check if Full-Text Search is installed
SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') IsFullTextInstalled;

--Get data about machine on which sql server is running
SELECT *
FROM sys.dm_os_host_info;

--Get property information about the server instance.
SELECT SERVERPROPERTY('Collation') Collation,
       SERVERPROPERTY('Edition') [Edition],
       SERVERPROPERTY('InstanceName') InstanceName,
       SERVERPROPERTY('IsFullTextInstalled') IsFullTextInstalled,
       SERVERPROPERTY('IsPolyBaseInstalled') IsPolyBaseInstalled,
       SERVERPROPERTY('LicenseType') LicenseType,
       SERVERPROPERTY('ProductUpdateLevel') ProductUpdateLevel,
       SERVERPROPERTY('SqlSortOrderName') SqlSortOrderName