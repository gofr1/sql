USE DEMO;

SELECT *
FROM sys.dm_tran_locks
WHERE resource_type <> 'DATABASE';
