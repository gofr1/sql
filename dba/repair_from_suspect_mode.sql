
-- If DataBase is in SUSPECT mode you need to set it into 
-- EMERGENCY mode
EXEC sp_resetstatus 'DEMO';
ALTER DATABASE DEMO SET EMERGENCY;

-- Check it
DBCC CheckDB(DEMO)
-- Take a complete backup of the database.

-- Switch to SINGLE_USER mode
ALTER DATABASE DEMO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- Use a REPAIR options
DBCC CheckDB('DEMO', REPAIR_ALLOW_DATA_LOSS)

-- Set it back to MULTI_USER
ALTER DATABASE DEMO SET MULTI_USER
