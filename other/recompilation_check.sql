USE DEMO;

SELECT * 
FROM sys.dm_xe_map_values 
WHERE name like '%recom%'

SELECT p.name + '.' + o.name action_name,*
FROM sys.dm_xe_objects o
INNER JOIN sys.dm_xe_packages p
    ON o.package_guid = p.guid
WHERE o.package_guid = '655fd93f-3364-40d5-b2ba-330f7ffb6491'
AND o.name  like '%recom%'
GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='SomethingRecompiled')
DROP EVENT SESSION SomethingRecompiled ON SERVER
GO

CREATE EVENT SESSION SomethingRecompiled ON SERVER
ADD EVENT sqlserver.sql_statement_recompile (
    ACTION (
        sqlserver.sql_text,
        sqlserver.plan_handle
    )
)
ADD TARGET package0.event_file (SET
    filename = N'/var/log/SomethingRecompiled.xel',
    metadatafile = N'/var/log/SomethingRecompiled.xem',
    max_file_size = (5)
)
GO

ALTER EVENT SESSION SomethingRecompiled
ON SERVER STATE = START
GO

DROP PROCEDURE IF EXISTS dbo.CheckRecompilationTemp
GO
DROP PROCEDURE IF EXISTS dbo.CheckRecompilationDeclareTable
GO

--Create a SP that will create and read from temp table
CREATE OR ALTER PROCEDURE dbo.CheckRecompilationTemp 
AS
BEGIN
    DROP TABLE IF EXISTS #tempTable;

    CREATE TABLE #tempTable (
        id int,
        pid int
    );

    WITH cte as (
        SELECT 1 as id
        UNION ALL
        SELECT id + 1
        FROM cte 
        WHERE id < 1000
    )

    INSERT INTO #tempTable 
    SELECT id, 
           id 
    FROM cte 
    OPTION (MAXRECURSION 0);

    SELECT * FROM #tempTable;

    DROP TABLE #tempTable;

END
GO

CREATE OR ALTER PROCEDURE dbo.CheckRecompilationDeclareTable
AS
BEGIN
    DECLARE @tempTable TABLE (
        id int,
        pid int
    );

    WITH cte as (
        SELECT 1 as id
        UNION ALL
        SELECT id + 1
        FROM cte 
        WHERE id < 1000
    )

    INSERT INTO @tempTable 
    SELECT id, 
           id 
    FROM cte 
    OPTION (MAXRECURSION 0);

    SELECT * FROM @tempTable;

END
GO

--Let's run this few times
EXEC dbo.CheckRecompilationTemp
GO
--Let's run this few times
EXEC dbo.CheckRecompilationDeclareTable
GO

ALTER EVENT SESSION SomethingRecompiled
ON SERVER STATE = STOP
GO

DROP EVENT SESSION SomethingRecompiled ON SERVER
GO

--Let's check what we get
WITH cte AS (
SELECT
    [XML Data] xml_data,
    [XML Data].value('(/event[@name=''sql_statement_recompile'']/@timestamp)[1]','DATETIME') AS [timestamp],
    [XML Data].value('(/event/data[@name=''source_database_id'']/value)[1]','varchar(max)') AS [source_database_id],
    [XML Data].value('(/event/data[@name=''recompile_cause'']/text)[1]','varchar(max)') AS [recompile_cause],
    [XML Data].value('(/event/data[@name=''object_id'']/text)[1]','varchar(max)') AS [object_id],
    [XML Data].value('(/event/data[@name=''object_type'']/text)[1]','varchar(max)') AS [object_type],
    [XML Data].value('(/event/action[@name=''plan_handle'']/value)[1]','varchar(max)') AS [plan_handle],
    [XML Data].value('(/event/action[@name=''sql_text'']/value)[1]','varchar(max)') AS [sql_text]
FROM
    (SELECT
        OBJECT_NAME              AS [Event], 
        CONVERT(XML, event_data) AS [XML Data]
    FROM
        sys.fn_xe_file_target_read_file
    ('/var/log/SomethingRecompiled*.xel',NULL,NULL,NULL)) as me
)
-- The query plan is recompiled 2 times at the first run
-- Further launches of SP doesn't trigger recompile
SELECT xml_data,
       timestamp,
       DB_NAME(source_database_id) source_database,
       recompile_cause,
       OBJECT_NAME(p.objectid) as object_name,
       object_type,
       sql_text,
       p.query_plan
FROM cte c 
CROSS APPLY sys.dm_exec_query_plan(CONVERT(varbinary(64),plan_handle,2)) as p
