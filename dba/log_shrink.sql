-- If the database is in the SIMPLE recovery model 
-- you can use the following statement to shrink the log file:
USE AdventureWorks2017;

-- check log file names
SELECT * 
FROM sys.master_files 
WHERE type_desc = 'LOG';
--or
SELECT * 
FROM sys.database_files;

-- shrink
DBCC SHRINKFILE ('AdventureWorks2017_log', 1);
        