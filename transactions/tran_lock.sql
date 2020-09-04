USE DEMO;

SELECT *
FROM sys.dm_tran_locks
WHERE resource_type <> 'DATABASE';

--They are (usually) set temporarily, and they cause deadlocking information to be dumped to the SQL management logs.
-- -1 enables the trace flag globally, if no digit - means only for current connection

DBCC TRACEON (1204, -1)
DBCC TRACEON (1222, -1)

DBCC TRACEOFF (1204, -1)
DBCC TRACEOFF (1222, -1)

--information about processes that are running on an instance of SQL Server
SELECT * 
FROM sys.sysprocesses 
WHERE blocked <> 0

--more convinient way to find deadlocks
SELECT bl.*, 
       c.*,
       r.*,
       w.*
FROM sys.dm_exec_connections c
INNER JOIN sys.dm_exec_requests r
    ON c.session_id = r.blocking_session_id
INNER JOIN sys.dm_os_waiting_tasks w
    ON r.session_id = w.session_id
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) bl;