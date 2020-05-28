exec sp_who;

-- current sessions
SELECT	r.database_id,
		d.[name],
		r.estimated_completion_time,
		r.cpu_time,
		r.total_elapsed_time,
		r.wait_type,
		r.last_wait_type,
		r.reads,
		r.writes,
		r.logical_reads,
		r.text_size,
		r.query_hash,
		r.query_plan_hash
FROM  sys.dm_exec_requests r
LEFT JOIN sys.databases d
	ON r.database_id = d.database_id
ORDER BY r.total_elapsed_time DESC;

-- check locks
SELECT distinct CAST (st.text as nvarchar(max)) AS [SQL Text],
		w.session_id,
		s.[host_name],
		s.login_name,
		w.wait_duration_ms,
		w.wait_duration_ms/1000/60 as [min],
		w.wait_type,
		w.resource_address,
		w.blocking_session_id,
		w.resource_description,
		s.is_user_process
FROM sys.dm_exec_connections AS c
left join sys.dm_exec_query_stats qs on c.most_recent_sql_handle = qs.sql_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
INNER JOIN sys.dm_os_waiting_tasks AS w ON w.session_id = c.session_id
INNER JOIN sys.dm_exec_sessions S ON S.session_id = w.session_id
WHERE --w.wait_duration_ms > 0  --and 
resource_description like '%lock%'
order by s.login_name desc;

-- jobs execution
SELECT
    ja.job_id,
    j.name AS job_name,
    ja.start_execution_date,      
    ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
    Js.step_name
FROM msdb.dbo.sysjobactivity ja 
INNER JOIN msdb.dbo.sysjobs j 
    ON ja.job_id = j.job_id
INNER JOIN msdb.dbo.sysjobsteps js
    ON ja.job_id = js.job_id
    AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
LEFT JOIN msdb.dbo.sysjobhistory jh 
    ON ja.job_history_id = jh.instance_id
WHERE ja.session_id = (
    SELECT TOP 1 session_id 
    FROM msdb.dbo.syssessions 
    ORDER BY agent_start_date DESC
)
AND start_execution_date is not null
AND stop_execution_date is null;

-- check seesions
SELECT distinct 
		s.session_id,
		s.login_name,
		c.client_net_address,
		w.wait_duration_ms,
		w.wait_duration_ms/1000/60 as [min],
		w.wait_type,
		w.resource_address,
		w.blocking_session_id,
		w.resource_description,
		CAST (st.text as nvarchar(max)) AS [SQL Text],
		s.is_user_process
FROM sys.dm_exec_sessions S
LEFT JOIN sys.dm_exec_connections AS c 
    ON S.session_id = c.session_id
LEFT JOIN sys.dm_exec_query_stats qs 
    ON c.most_recent_sql_handle = qs.sql_handle
INNER JOIN sys.dm_os_waiting_tasks AS w 
    ON w.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY s.is_user_process DESC, w.wait_duration_ms DESC;


SELECT TOP 5 total_worker_time/execution_count AS [Avg CPU Time],
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
       ((CASE qs.statement_end_offset
         WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
    END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY total_worker_time/execution_count DESC;


select distinct c.session_id,
	qt.[text],
	s.login_name,
	c.client_net_address,
	w.session_id,
	s.login_name,
	w.wait_duration_ms,
	w.wait_duration_ms/1000/60 as [min],
	w.wait_type,
	w.resource_address,
	w.blocking_session_id,
	w.resource_description
FROM sys.dm_exec_connections c
LEFT JOIN sys.dm_exec_query_stats qs 
    on c.most_recent_sql_handle = qs.sql_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
INNER JOIN sys.dm_exec_sessions S 
    ON S.session_id = c.session_id
LEFT JOIN sys.dm_os_waiting_tasks AS w 
    ON w.session_id = c.session_id 
ORDER BY s.login_name;

-- locks
SELECT DTL.resource_type,  
    CASE   
        WHEN DTL.resource_type IN ('DATABASE', 'FILE', 'METADATA') THEN DTL.resource_type  
        WHEN DTL.resource_type = 'OBJECT' THEN OBJECT_NAME(DTL.resource_associated_entity_id, SP.[dbid])  
        WHEN DTL.resource_type IN ('KEY', 'PAGE', 'RID') THEN   
            (  
            SELECT OBJECT_NAME([object_id])  
            FROM sys.partitions  
            WHERE sys.partitions.hobt_id =   
              DTL.resource_associated_entity_id  
            )  
        ELSE 'Unidentified'  
    END AS requested_object_name, 
    DTL.request_mode, 
    DTL.request_status,  
    DEST.TEXT, 
    SP.spid, 
    SP.blocked, 
    SP.status, 
    SP.loginame 
FROM sys.dm_tran_locks DTL  
INNER JOIN sys.sysprocesses SP  
    ON DTL.request_session_id = SP.spid   
--INNER JOIN sys.[dm_exec_requests] AS SDER ON SP.[spid] = [SDER].[session_id] 
CROSS APPLY sys.dm_exec_sql_text(SP.sql_handle) AS DEST  
WHERE SP.dbid = DB_ID()  
   AND DTL.[resource_type] <> 'DATABASE' 
ORDER BY DTL.[request_session_id];

