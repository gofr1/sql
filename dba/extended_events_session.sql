USE [master];

-- List current extended events sessions
SELECT * 
FROM sys.server_event_sessions;

-- List of ACTIONS
SELECT o.object_type,
       p.name + '.' + o.name action_name,
       o.[description],
       o.type_name,
       o.type_size,
       o.package_guid
FROM sys.dm_xe_objects o
INNER JOIN sys.dm_xe_packages p
    ON o.package_guid = p.guid
WHERE o.object_type = 'action' 
ORDER BY o.name;

-- List of EVENTS
SELECT o.object_type,
       p.name + '.' + o.name event_name,
       o.[description],
       o.type_name,
       o.type_size,
       o.package_guid
FROM sys.dm_xe_objects o
INNER JOIN sys.dm_xe_packages p
    ON o.package_guid = p.guid
WHERE o.object_type = 'event' 
ORDER BY o.name;
GO

-- List of MAPpings that could be found in resulted XML
SELECT p.name,
       o.name,
       o.object_type,
       o.[description],
       mv.map_key,
       mv.map_value
FROM sys.dm_xe_objects o
INNER JOIN sys.dm_xe_map_values mv
    ON mv.object_package_guid = o.package_guid AND o.name = mv.name
INNER JOIN sys.dm_xe_packages p
    ON o.package_guid = p.guid
ORDER BY o.name, mv.map_key;

-- Extended Event

--Check if the event session is already exisiting, if yes then drop it first
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='UserDefindException')
DROP EVENT SESSION UserDefindException ON SERVER
GO

--Creating a Extended Event session with CREATE EVENT SESSION command
CREATE EVENT SESSION UserDefindException ON SERVER

--Add events to this seesion with ADD EVENT clause
ADD EVENT sqlserver.error_reported (
--Specify what all you want to capture event data with ACTION Clause
ACTION (
sqlserver.session_id,
sqlserver.sql_text,
sqlserver.tsql_stack,
sqlserver.client_app_name, 
sqlserver.client_hostname,  
sqlserver.database_name, 
sqlserver.username
)
WHERE ([package0].[greater_than_int64]([severity], (10))) --Specify predicates to filter out your events
)

--Specify the target where event data will be written with ADD TARGET clause
-- ADD TARGET package0.ring_buffer
-- WITH (max_dispatch_latency = 1seconds)

ADD TARGET package0.event_file (SET
    filename = N'/var/log/UserDefindException.xel'
    ,metadatafile = N'/var/log/UserDefindException.xem'
    ,max_file_size = (5)
    ,max_rollover_files = (10)) WITH (max_dispatch_latency = 1seconds)
GO 


--This query will give details about event session, its events, actions, targets
SELECT [sessions].name AS SessionName, 
       sevents.package as PackageName,
       sevents.name AS EventName,
       sevents.predicate [Predicate], 
       sactions.name AS ActionName, 
       stargets.name AS TargetName
FROM sys.server_event_sessions [sessions]
INNER JOIN sys.server_event_session_events sevents
    ON sessions.event_session_id = sevents.event_session_id
INNER JOIN sys.server_event_session_actions sactions
    ON sessions.event_session_id = sactions.event_session_id
INNER JOIN sys.server_event_session_targets stargets
    ON sessions.event_session_id = stargets.event_session_id
WHERE sessions.name = 'UserDefindException'
GO 


--We need to enable event session to capture event and event data
ALTER EVENT SESSION UserDefindException
ON SERVER STATE = START
GO

SELECT * 
FROM sys.dm_xe_sessions
WHERE name like 'UserDefindException'
GO

-- Some failing queries
RAISERROR('User Defined Exception!!!', 16, 1)
GO 

SELECT 1/0
GO 


--This query will display the captured event data for specified event session
-- SELECT
--     t.c.query('.')                                                                  as EventXML,
--     t.c.value('(.[@name=''error_reported'']/@timestamp)[1]','DATETIME')             as [Timestamp],
--     t.c.value('(./action[@name=''database_name'']/value)[1]','varchar(max)')        as [Database],
--     t.c.value('(./data[@name=''message'']/value)[1]','varchar(max)')                as [Message],
--     t.c.value('(./action[@name=''sql_text'']/value)[1]','varchar(max)')             as [Statement]
-- FROM (
--     SELECT CAST(stargets.target_data AS XML) [XML Data]
--     FROM sys.dm_xe_session_targets stargets
--     INNER JOIN sys.dm_xe_sessions sessions
--         ON sessions.address = stargets.event_session_address
--     WHERE sessions.name = 'UserDefindException') as me
-- CROSS APPLY [XML Data].nodes('/RingBufferTarget/event') t(c)
-- GO 

-- or if you specify target as a file than you can read from file
SELECT
    [XML Data],
    [XML Data].value('(/event[@name=''error_reported'']/@timestamp)[1]','DATETIME')             AS [Timestamp],
    [XML Data].value('(/event/action[@name=''database_name'']/value)[1]','varchar(max)')        AS [Database],
    [XML Data].value('(/event/data[@name=''message'']/value)[1]','varchar(max)')                AS [Message],
    [XML Data].value('(/event/action[@name=''sql_text'']/value)[1]','varchar(max)')             AS [Statement]
FROM
    (SELECT
        OBJECT_NAME              AS [Event], 
        CONVERT(XML, event_data) AS [XML Data]
    FROM
        sys.fn_xe_file_target_read_file
    ('/var/log/UserDefindException*.xel',NULL,NULL,NULL)) as me;
GO

--Stop event session to capture event data
ALTER EVENT SESSION UserDefindException
ON SERVER STATE = STOP
GO


--To remove a event session, use DROP EVENT SESSION command
DROP EVENT SESSION UserDefindException ON SERVER
GO 