SELECT DB_NAME(),
       CURRENT_TIMESTAMP,
       @@VERSION;

SELECT
    db.name AS DBName,
    type_desc AS FileType,
    Physical_Name AS LocationOfFiles
FROM sys.master_files mf
INNER JOIN sys.databases db 
    ON db.database_id = mf.database_id;

SELECT *
FROM sys.configurations c 
WHERE c.[name] = 'max server memory (MB)';

SELECT database_id as Id,
       name as DBName,
       state_desc as CurrentState,
       page_verify_option_desc as PageOption,
       recovery_model_desc as RecoveryModel
FROM sys.databases;

-- Check if Full-Text Search is installed
SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')