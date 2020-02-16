RESTORE FILELISTONLY FROM DISK = N'WideWorldImporters-Full.bak'

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
TO N'/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1'

RESTORE FILELISTONLY FROM DISK = N'AdventureWorksDW2012.bak'

RESTORE DATABASE [AdventureWorksDW2012] 
FROM DISK = N'/var/sqlbackup/AdventureWorksDW2012.bak' 
WITH  NOUNLOAD, 
REPLACE, -- if database is currently online we should use replace to restore it
STATS = 5, -- NORECOVERY,
MOVE N'AdventureWorksDW2012' 
TO N'/var/opt/mssql/data/AdventureWorksDW2012.mdf',  
MOVE N'AdventureWorksDW2012_log' 
TO N'/var/opt/mssql/data/AdventureWorksDW2012_log.ldf'

RESTORE FILELISTONLY FROM DISK = N'AdventureWorks2012.bak'

RESTORE DATABASE [AdventureWorks2012] 
FROM DISK = N'/var/sqlbackup/AdventureWorks2012.bak' 
WITH  NOUNLOAD, 
REPLACE, -- if database is currently online we should use replace to restore it
STATS = 5, -- NORECOVERY,
MOVE N'AdventureWorks2012' 
TO N'/var/opt/mssql/data/AdventureWorks2012.mdf',  
MOVE N'AdventureWorks2012_log' 
TO N'/var/opt/mssql/data/AdventureWorks2012_log.ldf'