-- Resumable online indexes
USE WideWorldImporters
GO

-- Create an online, resumable index 
CREATE INDEX IX_Temp ON Application.People(PreferredName)
WITH (ONLINE = ON, RESUMABLE = ON, MAX_DURATION = 5 MINUTES);

-- pause index creation
ALTER INDEX IX_Temp ON Application.People PAUSE;

-- resume...
ALTER INDEX IX_Temp ON Application.People RESUME;

-- Abort
ALTER INDEX IX_Temp ON Application.People ABORT;

-- Check current state of resumable indexes
SELECT name ObjectName,
       index_ID,
       sql_text,
       last_max_dop_used,
       partition_number,
       state,
       state_desc,
       start_time,
       last_pause_time,
       total_execution_time,
       percent_complete,
       page_count
FROM sys.index_resumable_operations 
WHERE STATE = 1;

-- make online and resumable index default to DB
ALTER DATABASE SCOPED CONFIGURATION  
SET ELEVATE_ONLINE = WHEN_SUPPORTED;
ALTER DATABASE SCOPED CONFIGURATION  
SET ELEVATE_RESUMABLE = WHEN_SUPPORTED;

-- check current state of this database options
SELECT name as OptionName,
       value as CurrentState
FROM sys.database_scoped_configurations 
WHERE name in (
    'ELEVATE_ONLINE',
    'ELEVATE_RESUMABLE'
);

-- columnstore indexes can also be created and rebuild 
-- while table is online
CREATE CLUSTERED COLUMNSTORE INDEX cci 
ON  Application.People WITH (ONLINE = ON);

ALTER INDEX cci ON Application.People REBUILD WITH (ONLINE = ON);