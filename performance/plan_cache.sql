USE [master];

--Removes all elements from the plan cache, removes a specific plan from the plan cache by 
--specifying a plan handle or SQL handle, or removes all cache entries associated with a specified resource pool.
DBCC FreeProcCache;

SELECT cp.*
FROM sys.dm_exec_cached_plans cp;
--CROSS APPLY sys.dm_exec_plan_attributes (cp.plan_handle) pa;


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

