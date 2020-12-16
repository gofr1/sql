USE DEMO;

-- Showplan doesn't executes a query
-----------------------------------------------------------------------
--Displays an XML based estimated execution plan with cost estimations. 
--This is equivalent to the "Display Estimated Execution Plan..." option in SSMS.
SET SHOWPLAN_XML ON;
SELECT * FROM dbo.Person;
SET SHOWPLAN_XML OFF;

--Displays a basic text based estimated execution plan
SET SHOWPLAN_TEXT ON;
SELECT * FROM dbo.Person;
SET SHOWPLAN_TEXT OFF;

--Displays a text based estimated execution plan with cost estimations
SET SHOWPLAN_ALL ON;
SELECT * FROM dbo.Person;
SET SHOWPLAN_ALL OFF;

--This will execute the query
-----------------------------------------------------------------------
--Executes the query and displays a text based actual execution plan.
SET STATISTICS PROFILE ON;
SELECT * FROM dbo.Person;
SET STATISTICS PROFILE OFF;

--Executes the query and displays an XML based actual execution plan. 
--This is equivalent to the "Include Actual Execution Plan" option in SSMS
SET STATISTICS XML ON;
SELECT * FROM dbo.Person;
SET STATISTICS XML OFF;

--Inspect the query cache
SELECT UseCounts, 
       Cacheobjtype, 
       Objtype, 
       [TEXT],
       query_plan
FROM sys.dm_exec_cached_plans 
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
CROSS APPLY sys.dm_exec_query_plan(plan_handle)