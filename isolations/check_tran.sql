USE [master]

SELECT *
FROM sys.dm_tran_locks
WHERE resource_type <> 'DATABASE'
and request_session_id = 83 ;