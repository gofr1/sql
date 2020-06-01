-- Dynamic Management Views
USE DEMO;

SELECT *
FROM sys.dm_os_sys_memory;

SELECT *
FROM sys.dm_exec_connections;

SELECT *
FROM sys.dm_db_log_space_usage;