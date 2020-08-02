USE tempdb
GO

--Find the event name allows to look at wait statistics
SELECT xp.[name] as package_name,
       xo.[name] as object_name,
       xo.object_type,
       xo.capabilities_desc,
       xo.[description] as object_desc,
       xp.[description] as package_desc
FROM sys.dm_xe_objects xo 
INNER JOIN sys.dm_xe_packages xp
    ON xp.[guid] = xo.[package_guid]
WHERE xo.[object_type] = 'event' AND xo.name LIKE '%wait%'
ORDER BY xp.[name]
GO

--Find the columns that are  available to track for the wait_info event
SELECT name,
       column_id,
       object_name,
       type_name,
       column_type,
       [description]
FROM sys.dm_xe_object_columns
WHERE [object_name] = 'wait_info';
GO

--Find the additional columns that can be tracked
SELECT xp.name as package_name,
       xo.name as object_name,
       xo.[description] as object_desc,
       xo.capabilities_desc,
       xo.type_name,
       xp.[description] as package_desc
FROM sys.dm_xe_objects xo 
INNER JOIN sys.dm_xe_packages xp
   ON xp.[guid] = xo.[package_guid]
WHERE xo.[object_type] = 'action'
ORDER BY xp.[name];
GO

--Let's use Extended Events to monitor tempdb

--Drop the event if it already exists
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='MonitorWaitInfoTempdb')
DROP EVENT SESSION MonitorWaitInfoTempdb ON SERVER; 
GO 
--Create the event 
CREATE EVENT SESSION MonitorWaitInfoTempdb ON SERVER 
--We are looking at wait info only
ADD EVENT sqlos.wait_info
( 
   --Add additional columns to track
   ACTION (
       sqlserver.database_id, 
       sqlserver.sql_text, 
       sqlserver.session_id, 
       sqlserver.tsql_stack)  
    WHERE sqlserver.database_id = 2 --filter database id = 2 i.e tempdb
    --This allows us to track wait statistics at database granularity
) --As a best practise use asynchronous file target, reduces overhead.
ADD TARGET package0.asynchronous_file_target(
    SET filename='/var/log/MonitorWaitInfoTempdb.etl', 
    metadatafile='/var/log/MonitorWaitInfoTempdb.mta')
GO

--Now start the session
ALTER EVENT SESSION MonitorWaitInfoTempdb ON SERVER
STATE = START;
GO



SELECT WaitTypeName,
       SUM(TotalDuration) AS TotalDuration,
       SUM(SignalDuration) AS TotalSignalDuration
FROM (
SELECT xmldata.value('(/event/@name)[1]', 'nvarchar(50)')                               AS EventName,
       xmldata.value('(/event/@timestamp)[1]','DATETIME')                               AS [Timestamp],
       xmldata.value('(/event/data[@name=''message'']/value)[1]','varchar(max)')        AS [Message],
       xmldata.value('(/event/action[@name=''sql_text'']/value)[1]','varchar(max)')     AS [Statement],
       xmldata.value('(/event/data[@name=''wait_type'']/value)[1]', 'nvarchar(50)')     AS WaitTypeValue,
       xmldata.value('(/event/data[@name=''wait_type'']/text)[1]', 'nvarchar(50)')      AS WaitTypeName,
       xmldata.value('(/event/data[@name=''duration'']/value)[1]', 'int')               AS TotalDuration,
       xmldata.value('(/event/data[@name=''signal_duration'']/value)[1]', 'int')        AS SignalDuration,
       xmldata.value('(/event/action[@name=''database_id'']/value)[1]', 'nvarchar(50)') AS DatabaseID,
       xmldata.value('(/event/action[@name=''session_id'']/value)[1]', 'nvarchar(50)')  AS SessionID
FROM (
    SELECT CONVERT(xml, event_data) AS xmldata
    FROM sys.fn_xe_file_target_read_file ('/var/log/MonitorWaitInfoTempdb*.etl', '/var/log/MonitorWaitInfoTempdb*.mta', NULL, NULL)
) me ) t 
WHERE WaitTypeName NOT IN ('SLEEP_TASK')
GROUP BY WaitTypeName
ORDER BY TotalDuration
GO

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
    ('/var/log/MonitorWaitInfoTempdb*.xel',NULL,NULL,NULL)) as me;
GO

--Stop event session to capture event data
ALTER EVENT SESSION MonitorWaitInfoTempdb
ON SERVER STATE = STOP
GO


--To remove a event session, use DROP EVENT SESSION command
DROP EVENT SESSION MonitorWaitInfoTempdb ON SERVER
GO 