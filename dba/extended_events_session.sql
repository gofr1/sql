-- List current extended events sessions
SELECT * 
FROM sys.server_event_sessions

-- List of default actions
SELECT p.name + '.' + o.name action_name
FROM sys.dm_xe_objects o
INNER JOIN sys.dm_xe_packages p
    ON o.package_guid = p.guid
WHERE o.object_type = 'action' 
ORDER BY o.name
GO

--Check if the event session is already exisiting, if yes then drop it first
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='MonitorUserDefinedException')
DROP EVENT SESSION MonitorUserDefinedException ON SERVER
GO

--Creating a Extended Event session with CREATE EVENT SESSION command
CREATE EVENT SESSION MonitorUserDefinedException ON SERVER

--Add events to this seesion with ADD EVENT clause
ADD EVENT sqlserver.error_reported (
--Specify what all you want to capture event data with ACTION Clause
ACTION (
sqlserver.session_id,
sqlserver.sql_text,
sqlserver.tsql_stack
)
WHERE ([package0].[greater_than_int64]([severity], (10))) --Specify predicates to filter out your events
)

--Specify the target where event data will be written with ADD TARGET clause
ADD TARGET package0.ring_buffer
WITH (max_dispatch_latency = 1seconds)
GO 


--This query will give details about event session, its events, actions, targets
SELECT sessions.name AS SessionName, 
       sevents.package as PackageName,
       sevents.name AS EventName,
       sevents.predicate, 
       sactions.name AS ActionName, 
       stargets.name AS TargetName
FROM sys.server_event_sessions sessions
INNER JOIN sys.server_event_session_events sevents
    ON sessions.event_session_id = sevents.event_session_id
INNER JOIN sys.server_event_session_actions sactions
    ON sessions.event_session_id = sactions.event_session_id
INNER JOIN sys.server_event_session_targets stargets
    ON sessions.event_session_id = stargets.event_session_id
WHERE sessions.name = 'MonitorUserDefinedException'
GO 


--We need to enable event session to capture event and event data
ALTER EVENT SESSION MonitorUserDefinedException
ON SERVER STATE = START
GO
SELECT * FROM sys.dm_xe_sessions
WHERE name like 'MonitorUserDefinedException'
GO
RAISERROR('User Defined Exception!!!', 16, 1)
GO 


--This query will display the captured event data for specified event session
SELECT CAST(stargets.target_data AS XML)
FROM sys.dm_xe_session_targets stargets
INNER JOIN sys.dm_xe_sessions sessions
    ON sessions.address = stargets.event_session_address
WHERE sessions.name = 'MonitorUserDefinedException'
GO 


--You can stop event session to capture event data
ALTER EVENT SESSION MonitorUserDefinedException
ON SERVER STATE = STOP
GO


--To remove a event session, use DROP EVENT SESSION command
DROP EVENT SESSION MonitorUserDefinedException ON SERVER
GO 