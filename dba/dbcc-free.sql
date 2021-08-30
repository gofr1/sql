--The following example flushes the distributed query cache.

USE AdventureWorks2012;  
GO  
DBCC FREESESSIONCACHE WITH NO_INFOMSGS;  
GO  

-- Releases all unused cache entries from all caches. 
-- The SQL Server Database Engine proactively cleans up unused cache entries in the background 
-- to make memory available for current entries. 
-- However, you can use this command to manually remove unused entries from every cache or 
-- from a specified Resource Governor pool cache.

-- To list the available pool names run:
SELECT * 
FROM sys.dm_os_memory_clerks;
GO 

-- Clean all the caches with entries specific to the resource pool named "default".  
DBCC FREESYSTEMCACHE ('ALL', default);