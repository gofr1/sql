USE [master];

--Removes all elements from the plan cache, removes a specific plan from the plan cache by 
--specifying a plan handle or SQL handle, or removes all cache entries associated with a specified resource pool.
DBCC FreeProcCache;

SELECT *
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) eqp

--For further details lets deep inside
WITH plan_cache AS (
    SELECT cp.bucketid,
           cp.cacheobjtype,
           cp.objtype,
           CONVERT(varbinary(64), pa.value) [sql_handle]
    FROM sys.dm_exec_cached_plans cp
    CROSS APPLY sys.dm_exec_plan_attributes (cp.plan_handle) pa
    WHERE cp.usecounts >= 100 AND pa.attribute = 'sql_handle'
)

SELECT pc.bucketid, 
       pc.cacheobjtype,
       pc.objtype,
       st.[text]  -- Here we can find our query --*(@i int)SELECT * FROM dbo.IndexTest WHERE id = @i
FROM plan_cache pc 
CROSS APPLY sys.dm_exec_sql_text(pc.[sql_handle]) st;

--Find a plan xml
SELECT d.name [database_name],
	   est.text AS tsql_text,
	   qs.creation_time, 
	   qs.execution_count,
	   qs.total_worker_time AS total_cpu_time,
	   qs.total_elapsed_time, 
	   qs.total_logical_reads, 
	   qs.total_physical_reads, 
	   eqp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) est
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) eqp
INNER JOIN sys.databases d
ON est.dbid = d.database_id
WHERE est.[text] LIKE '%IndexTest%';

--Let's select multiple times from some table with hardcoded values
USE DEMO;

DECLARE @n int = 100,
        @sql nvarchar(512)

WHILE @n > 0
BEGIN
    SET @sql = CONCAT(N'SELECT * FROM dbo.IndexTest WHERE id = ', @n)
    EXEC(@sql)
    SET @n -= 1
END;

--There will be +100 cached plans on the similar query - that's a plan cache pollution

--Now lets clear all and rewrite
DECLARE @i int = 100,
        @sqli nvarchar(512) = N'SELECT * FROM dbo.IndexTest WHERE id = @i',
        @params nvarchar(512) = N'@i int'

WHILE @i > 0
BEGIN
    EXEC sp_executesql @sqli, @params, @i = @i
    SET @i -= 1
END;

--Now check cached plans, one plan was reused 100 times.

