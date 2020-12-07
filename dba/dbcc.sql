-- DataBase Console Commands

DBCC CheckDB(AdventureWorks2012)
DBCC SQLPERF(LOGSPACE)
DBCC HELP('CheckDB')
DBCC HELP('?')

USE DEMO;

--SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

DBCC USEROPTIONS;

-- Removes all clean buffers from the buffer pool, and columnstore objects from the columnstore object pool.
DBCC DROPCLEANBUFFERS;

-- DBCC LOGININFO is used to see information about virtual logs (VDF) inside the log file. 
-- It gives the tabular output containing FileID, FileSize, StartOffset, FSeqNo, Status, 
-- Parity, CreateLSN columns. Each row corresponds to one VLF.
DBCC LOGINFO;

