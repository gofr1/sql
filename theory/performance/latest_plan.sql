USE DEMO;

-- LAST_QUERY_PLAN_STATS = { ON | OFF}
-- APPLIES TO: SQL Server (Starting with SQL Server 2019 (15.x)) (feature is in public preview)
-- Allows you to enable or disable collection of the last query plan statistics 
-- (equivalent to an actual execution plan) in sys.dm_exec_query_plan_stats.


-- A new database scoped configuration LAST_QUERY_PLAN_STATS, 
-- or you can turn it on at the server level using a trace flag, 2451
ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;

-- argument is the plan_handle can be obtained from the following dynamic management objects:
--   sys.dm_exec_cached_plans (Transact-SQL)
--   sys.dm_exec_query_stats (Transact-SQL)
--   sys.dm_exec_requests (Transact-SQL)
--   sys.dm_exec_procedure_stats (Transact-SQL)
--   sys.dm_exec_trigger_stats (Transact-SQL)

SELECT deqps.query_plan
FROM sys.dm_exec_procedure_stats AS deps
-- Returns the equivalent of the last known actual execution plan for a previously cached query plan.
CROSS APPLY sys.dm_exec_query_plan_stats(deps.plan_handle) AS deqps
WHERE deps.object_id = OBJECT_ID('dbo.GetIndexTest')
GO

CREATE OR ALTER PROCEDURE dbo.GetIndexTest
AS
SELECT * FROM dbo.IndexTest
GO

EXEC dbo.GetIndexTest;