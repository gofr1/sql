USE DEMO;

SELECT * 
FROM sys.dm_xe_map_values 
WHERE name like '%cursor%';

SELECT p.name + '.' + o.name action_name, o.*,
       o.[description]
FROM sys.dm_xe_objects o
INNER JOIN sys.dm_xe_packages p
    ON o.package_guid = p.guid
WHERE o.name  like '%cursor_%' and o.object_type = 'event'
GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='CursorDetail')
DROP EVENT SESSION CursorDetail ON SERVER
GO

CREATE EVENT SESSION CursorDetail ON SERVER
ADD EVENT sqlserver.cursor_manager_cursor_begin (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_end (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_cache_hit (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cached_cursor_added (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cached_cursor_removed (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_memory_usage (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_worktable_use_begin (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_worktable_use_end (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_plan_begin (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_plan_end (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_manager_cursor_cache_attempt (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_open (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_prepare (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_execute (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_recompile (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_implicit_conversion (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_unprepare (ACTION (sqlserver.sql_text)),
ADD EVENT sqlserver.cursor_close (ACTION (sqlserver.sql_text))
ADD TARGET package0.event_file (SET
    filename = N'/var/log/CursorDetail.xel',
    max_file_size = (50)
) WITH (
    TRACK_CAUSALITY=ON
)
-- ADD TARGET package0.ring_buffer
-- WITH (max_dispatch_latency = 1seconds)

GO

ALTER EVENT SESSION CursorDetail
ON SERVER STATE = START
GO

DECLARE 
    @ProductNumber NVARCHAR(25), 
    @ProductName   NVARCHAR(max);

DECLARE cursor_product CURSOR
FOR SELECT TOP 20
        ProductNumber, 
        [Name] as ProductName
    FROM AdventureWorks2017.Production.Product;

OPEN cursor_product;

FETCH NEXT FROM cursor_product INTO 
    @ProductNumber, 
    @ProductName;

WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @ProductNumber + @ProductName;
        FETCH NEXT FROM cursor_product INTO 
            @ProductNumber, 
            @ProductName;
    END;

CLOSE cursor_product;
DEALLOCATE cursor_product;

ALTER EVENT SESSION CursorDetail
ON SERVER STATE = STOP
GO

DROP EVENT SESSION CursorDetail ON SERVER
GO

-- SELECT
--         OBJECT_NAME              AS [Event], 
--         CONVERT(XML, event_data) AS [XML Data]
--     FROM
--         sys.fn_xe_file_target_read_file
--     ('/var/log/CursorDetail*.xel',NULL,NULL,NULL)

SELECT
    t.c.query('.')                                                                  as EventXML,
    t.c.value('(.[@name=''error_reported'']/@timestamp)[1]','DATETIME')             as [Timestamp],
    t.c.value('(./action[@name=''database_name'']/value)[1]','varchar(max)')        as [Database],
    t.c.value('(./data[@name=''message'']/value)[1]','varchar(max)')                as [Message],
    t.c.value('(./action[@name=''sql_text'']/value)[1]','varchar(max)')             as [Statement]
FROM (
    SELECT CAST(stargets.target_data AS XML) [XML Data]
    FROM sys.dm_xe_session_targets stargets
    INNER JOIN sys.dm_xe_sessions sessions
        ON sessions.address = stargets.event_session_address
    WHERE sessions.name = 'CursorDetail') as me
CROSS APPLY [XML Data].nodes('/RingBufferTarget/event') t(c)
GO 

SELECT CAST(stargets.target_data AS XML) [XML Data]
FROM sys.dm_xe_session_targets stargets
INNER JOIN sys.dm_xe_sessions sessions
    ON sessions.address = stargets.event_session_address
WHERE sessions.name = 'CursorDetail'

SELECT *
FROM  sys.dm_xe_sessions sessions
WHERE sessions.name = 'CursorDetail'