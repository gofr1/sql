USE master;
-- path to errorlog files:
-- /var/opt/mssql/log/errorlog

-- sp_readerrorlog PARAMETERS:
-- Value of error log file you want to read: 
--    0 = current, 
--    1 = Archive #1, 
--    2 = Archive #2, 
--    etc...
-- Log file type: 
--    1 or NULL = error log, 
--    2 = SQL Agent log
-- Search string 1: String one you want to search for
-- Search string 2: String two you want to search for 
--                  to further refine the results

-- current log
EXEC sp_readerrorlog 0, 1;

-- search for failures in sixth log file
EXEC sp_readerrorlog 6, 1, 'failure';


-- xp_readerrorlog PARAMETERS:
-- Value of error log file you want to read: 
--    0 = current, 
--    1 = Archive #1, 
--    2 = Archive #2, 
--    etc...
-- Log file type: 
--    1 or NULL = error log, 
--    2 = SQL Agent log
-- Search string 1: String one you want to search for
-- Search string 2: String two you want to search for 
--                  to further refine the results
-- Search from start time
-- Search to end time
-- Sort order for results: N'asc' = ascending, N'desc' = descending

-- current errorlog 
EXEC master.dbo.xp_readerrorlog 0, 1, NULL, NULL, NULL, NULL, N'desc';

-- backup failed search
EXEC master.dbo.xp_readerrorlog 0, 1, N'backup', N'failed', NULL, NULL, N'asc';
