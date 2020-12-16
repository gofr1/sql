USE [master];

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name='DeadlockMonitor')
DROP EVENT SESSION DeadlockMonitor ON SERVER
GO

CREATE EVENT SESSION DeadlockMonitor ON SERVER
--Occurs when an attempt to acquire a lock is canceled for the victim of a deadlock.
ADD EVENT sqlserver.lock_deadlock (
    ACTION (
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.tsql_stack,
        sqlserver.client_app_name, 
        sqlserver.client_hostname,  
        sqlserver.database_name, 
        sqlserver.username
    )
),
--Occurs when an attempt to acquire a lock generates a deadlock. This event is raised for each participant in the deadlock.
ADD EVENT sqlserver.lock_deadlock_chain (
    ACTION (
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.tsql_stack,
        sqlserver.client_app_name, 
        sqlserver.client_hostname,  
        sqlserver.database_name, 
        sqlserver.username
    )
),
--Produces a deadlock report in XML format.
ADD EVENT sqlserver.xml_deadlock_report (
    ACTION (
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.tsql_stack,
        sqlserver.client_app_name, 
        sqlserver.client_hostname,  
        sqlserver.database_name, 
        sqlserver.username
    )
)
ADD TARGET package0.event_file (SET
    filename = N'/var/log/DeadlockMonitor.xel'
    ,metadatafile = N'/var/log/DeadlockMonitor.xem'
    ,max_file_size = (5)
    ,max_rollover_files = (10)) WITH (max_dispatch_latency = 1seconds)
GO 

ALTER EVENT SESSION DeadlockMonitor
ON SERVER STATE = START
GO

--Go to deadlock_demo*.sql

ALTER EVENT SESSION DeadlockMonitor
ON SERVER STATE = STOP
GO

DROP EVENT SESSION DeadlockMonitor ON SERVER
GO 

--Here we got xml info regarding deadlocks
SELECT CONVERT(XML, event_data) AS deadlock_xml
FROM sys.fn_xe_file_target_read_file ('/var/log/DeadlockMonitor*.xel',NULL,NULL,NULL);
