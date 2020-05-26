USE master;

-- at first check the backup file
-- pay attention to paths
RESTORE FILELISTONLY FROM DISK = N'WideWorldImporters-Full.bak';

-- if you are restoring f.e. some db from windows environment
-- you will need to move files properly with MOVE command
RESTORE DATABASE [WideWorldImporters] 
FROM DISK = N'/var/sqlbackup/WideWorldImporters-Full.bak' 
WITH  NOUNLOAD, 
REPLACE, -- if database is currently online we should use replace to restore it
STATS = 5, -- NORECOVERY,
MOVE N'WWI_Primary' 
TO N'/var/opt/mssql/data/WideWorldImporters.mdf',  
MOVE N'WWI_UserData' 
TO N'/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
MOVE N'WWI_Log' 
TO N'/var/opt/mssql/data/WideWorldImporters.ldf',  
MOVE N'WWI_InMemory_Data_1' 
TO N'/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1';

/*
RESTORE DATABASE [AdventureWorks2017] 
FROM DISK = N'/var/sqlbackup/AdventureWorks2017.bak' 
WITH  NOUNLOAD, 
REPLACE, -- if database is currently online we should use replace to restore it
STATS = 5, -- NORECOVERY,
MOVE N'AdventureWorks2017' 
TO N'/var/opt/mssql/data/AdventureWorks2017.mdf',  
MOVE N'AdventureWorks2017_log' 
TO N'/var/opt/mssql/data/AdventureWorks2017_log.ldf'
*/