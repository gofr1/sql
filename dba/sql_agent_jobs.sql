USE msdb;

SELECT *
FROM dbo.sysjobs;

SELECT j.name as job_name,
       h.step_name,
       dbo.agent_datetime(h.run_date, h.run_time) as runn_date_time,
       h.run_duration --duration stored in HHMMSS format similar to run_time
FROM dbo.sysjobs j 
INNER JOIN dbo.sysjobhistory h 
    ON j.job_id = h.job_id;
--WHERE j.enabled = 1  --Only Enabled Jobs

--Adding a job with step
EXEC dbo.sp_add_job @job_name = N'Test of SQL Agent' ;  

EXEC sp_add_jobstep  
    @job_name = N'Test of SQL Agent',  
    @step_name = N'Step 1',  
    @subsystem = N'TSQL',  
    @command = N'SELECT 1 as digit';  

-- Add a schedule
EXEC dbo.sp_add_schedule  
    @schedule_name = N'RunOnce',  
    @freq_type = 1,  
    @active_start_time = 130500 ;  --HHMMSS format

-- Add schedule to a job
EXEC sp_attach_schedule  
   @job_name = N'Test of SQL Agent',  
   @schedule_name = N'RunOnce';  

--Targets the specified job at the specified server.
EXEC dbo.sp_add_jobserver  
    @job_name = N'Test of SQL Agent';
    --@server_name = N'LOCALHOST'; 

EXEC dbo.sp_delete_job
    @job_name = N'Test of SQL Agent';
    --@originating_server = ] 'server' ]   
    --@delete_history = --When delete_history is 1, the job history for the job is deleted. When delete_history is 0, the job history is not deleted.  
    --@delete_unused_schedule = --When delete_unused_schedule is 1, schedules attached to this job are deleted if no other jobs reference the schedule. When delete_unused_schedule is 0, the schedules are not deleted.