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


