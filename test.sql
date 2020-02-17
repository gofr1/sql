SELECT DB_NAME(),
       CURRENT_TIMESTAMP,
       @@VERSION;


SELECT
    db.name AS DBName,
    type_desc AS FileType,
    Physical_Name AS LocationOfFiles,
    db.state_desc as CurrentState
FROM
    sys.master_files mf
INNER JOIN 
    sys.databases db ON db.database_id = mf.database_id;

SELECT *
FROM sys.configurations c 
WHERE c.[name] = 'max server memory (MB)'

SELECT * FROM sys.databases;
