USE [master];

-- The cost threshold for parallelism option specifies the threshold at which SQL Server 
--creates and runs parallel plans for queries. SQL Server creates and runs a parallel plan 
--for a query only when the estimated cost to run a serial plan for the same query is higher 
--than the value set in cost threshold for parallelism. 
-- The cost refers to an estimated cost required to run the serial plan on a specific hardware 
--configuration, and is not a unit of time. 
-- The cost threshold for parallelism option can be set to any value from 0 through 32767. 
--The default value is 5.

SELECT (cpu_count / hyperthread_ratio) AS sockets,
       cpu_count, --logical CPUs
       hyperthread_ratio  
FROM sys.dm_os_sys_info;

SELECT c.[name],
       c.[description],
       c.[value],
       c.minimum,
       c.maximum,
       c.value_in_use,
       c.is_dynamic,
       c.is_advanced
FROM sys.configurations c 
WHERE c.[name] IN (
    'max degree of parallelism',
    'cost threshold for parallelism'
);

--To reconfigure use 
EXEC sp_configure 'show advanced options', 0;  
RECONFIGURE;
EXEC sp_configure 'cost threshold for parallelism', 10;   
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;  
RECONFIGURE;
