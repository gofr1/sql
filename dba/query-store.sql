--! The SQL Server Query Store
USE [master];
DROP DATABASE IF EXISTS [QueryStoreDB];
CREATE DATABASE [QueryStoreDB];

--? Is used for:
-- Find the most expensive queries for CPU, I/O, Memory etc.
-- Get full history of query executions.
-- Get information about query regressions.
-- Determine how many times a query was executed in the given range of time.

--? Features:
-- Is per-database-level feature which means that it can be enabled on every SQL database separately.
-- It is not an instance level setting.
-- Allows analyzing query performance using built-in reports and DMWs.
-- Is available on every SQL Server edition.
-- On Azure databases is enabled by default. 

--? Modes:
-- Off – The SQL Server Query Store turned off
-- Read Only – This mode indicates that new query runtime statistics or executed plans will not be tracked (collected)
-- Read Write – Allows capturing query executed plans and query runtime statistics 

ALTER DATABASE [QueryStoreDB]
SET QUERY_STORE = ON 
(
    OPERATION_MODE = READ_WRITE,        -- Modes 
    CLEANUP_POLICY = ( 
        STALE_QUERY_THRESHOLD_DAYS = 90 -- Time-based cleanup policy that controls the retention period of persisted runtime statistics and inactive queries, expressed in days.
    ), 
    DATA_FLUSH_INTERVAL_SECONDS = 900,  -- It defines the frequency to persist collected runtime statistics to disk. 
    MAX_STORAGE_SIZE_MB = 1000,         -- Specifies the limit for the data space that Query Store takes inside your database.
    INTERVAL_LENGTH_MINUTES = 60,       -- Defines the level of granularity for the collected runtime statistic
    SIZE_BASED_CLEANUP_MODE = AUTO,     -- Specifies whether automatic data cleanup takes place when Query Store data size approaches the limit. 
    MAX_PLANS_PER_QUERY = 200,
    WAIT_STATS_CAPTURE_MODE = ON,
    QUERY_CAPTURE_MODE = CUSTOM,
    QUERY_CAPTURE_POLICY = (
        STALE_CAPTURE_POLICY_THRESHOLD = 24 HOURS,
        EXECUTION_COUNT = 30,
        TOTAL_COMPILE_CPU_TIME_MS = 1000,
        TOTAL_EXECUTION_CPU_TIME_MS = 100
    )
);

USE [QueryStoreDB];

SELECT actual_state_desc, 
       desired_state_desc, 
       current_storage_size_mb,
       max_storage_size_mb, 
       readonly_reason
FROM sys.database_query_store_options;
--* actual_state_desc   desired_state_desc   current_storage_size_mb   max_storage_size_mb   readonly_reason
--* READ_WRITE          READ_WRITE           0                         1000                  0

---------------------------------------------------------------------
-- Emulate some activity
SELECT *
INTO dbo.TestQueryStore 
FROM DEMO.dbo.SearchARGumentABLE

SELECT *
FROM dbo.TestQueryStore

SELECT DISTINCT OrderId 
FROM dbo.TestQueryStore
WHERE OrderDate > '1992-10-01' AND OrderDate < '1993-10-01'

---------------------------------------------------------------------
-- Check
SELECT *
FROM sys.query_store_plan p
INNER JOIN sys.query_store_query q 
    ON p.query_id = q.query_id


USE [master];
-- Clean up Query Store data by using the following statement:
ALTER DATABASE [QueryStoreDB] SET QUERY_STORE CLEAR;

USE [QueryStoreDB]
-- Check the status of forced plans 
SELECT p.plan_id, 
       p.query_id, 
       q.object_id as containing_object_id,
       force_failure_count, 
       last_force_failure_reason_desc
FROM sys.query_store_plan p
INNER JOIN sys.query_store_query q 
    ON p.query_id = q.query_id
WHERE is_forced_plan = 1;

