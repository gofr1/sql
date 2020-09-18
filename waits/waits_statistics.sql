/*
Query life cycle:
RUNNING ------
 |            \
 |       /-----SUSPENDED - f.e. waits to load some pages in buffer pool or waiting to require a latch etc.
RUNNABLE - ready to run but need cpu
*/
SELECT @@SPID

USE DEMO;

DROP TABLE IF EXISTS dbo.WaitsCheck;

CREATE TABLE dbo.WaitsCheck (
    Id int IDENTITY(1,1) NOT NULL,
    Digit int,
    Comment varchar(8000),
    CONSTRAINT [PK_WaitsCheck_Id] PRIMARY KEY (Id)
);

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name = 'CollectWaitStatistics')
DROP EVENT SESSION CollectWaitStatistics ON SERVER
GO

CREATE EVENT SESSION CollectWaitStatistics 
ON SERVER
ADD EVENT sqlos.wait_info (
    WHERE sqlserver.session_id = 164 -- @@SPID
)
ADD TARGET package0.event_file(
    SET FILENAME = N'/var/log/CollectWaitStatistics.xel'
)
GO

ALTER EVENT SESSION CollectWaitStatistics
ON SERVER STATE = START
GO

DECLARE @i int = 200

WHILE @i > 0
BEGIN
    BEGIN TRANSACTION

    INSERT INTO dbo.WaitsCheck (Digit, Comment)
    SELECT RAND(),
           REPLICATE('a', 8000)

    COMMIT TRANSACTION

    SET @i -= 1
END


DROP EVENT SESSION CollectWaitStatistics ON SERVER
GO 

WITH cws AS (
    SELECT xml_data.value('(/event[@name=''wait_info'']/@timestamp)[1]','DATETIME') [timestamp],
           xml_data.value('(/event/data[@name=''wait_type'']/text)[1]','varchar(max)') [wait_type],
           xml_data.value('(/event/data[@name=''duration'']/value)[1]','int') [duration],
           xml_data.value('(/event/data[@name=''wait_resource'']/value)[1]','varchar(max)') [wait_resource]
    FROM (
        SELECT CONVERT(XML, event_data) AS xml_data
        FROM sys.fn_xe_file_target_read_file (
            '/var/log/CollectWaitStatistics*.xel', --path
            NULL, --mdpath
            NULL, --initial_file_name
            NULL --initial_offset
        )
    ) as me
)

SELECT wait_type,
       COUNT(*) as cnt,
       SUM(duration) as total_duration
FROM cws
GROUP BY wait_type;

