-- Implicit conversion in SQL Server
USE DEMO;
GO

-- Some data 
DROP TABLE IF EXISTS dbo.TestPrecedence
 
CREATE TABLE dbo.TestPrecedence (
    NumericColumn INT
)
 
INSERT INTO dbo.TestPrecedence 
VALUES (1), (2), (3);

-- Example
SET STATISTICS PROFILE, XML ON;

SELECT * 
FROM dbo.TestPrecedence 
WHERE NumericColumn = N'1';

--*    <ScalarOperator ScalarString="[DEMO].[dbo].[TestPrecedence].[NumericColumn]=CONVERT_IMPLICIT(int,[@1],0)">
-- The query optimizer converts the textual data type to an integer because INT data type precedence is higher than NVARCHAR

SET STATISTICS PROFILE, XML OFF;

SELECT * 
FROM dbo.TestPrecedence 
WHERE NumericColumn = N'A';

--! Msg 245, Level 16, State 1, Line 1
--! Conversion failed when converting the nvarchar value 'A' to data type int. 

USE WideWorldImporters;
GO

SET STATISTICS PROFILE, XML ON;

SELECT TransactionDate,
       IsFinalized
FROM [Sales].[CustomerTransactions]
where IsFinalized LIKE '1%';

--! <Warnings>
--!   <PlanAffectingConvert ConvertIssue="Cardinality Estimate" Expression="CONVERT_IMPLICIT(varchar(1),[WideWorldImporters].[Sales].[CustomerTransactions].[IsFinalized],0)"></PlanAffectingConvert>
--!   <PlanAffectingConvert ConvertIssue="Seek Plan" Expression="CONVERT_IMPLICIT(varchar(1),[WideWorldImporters].[Sales].[CustomerTransactions].[IsFinalized],0)&gt;=&apos;1&apos;"></PlanAffectingConvert>
--! </Warnings>
-- Here we got 2 warnings

SET STATISTICS PROFILE, XML OFF;

-- To monitor implicit conversions we can use eXtended Events

CREATE EVENT SESSION [ImplicitConversionCapture] ON SERVER 
ADD EVENT sqlserver.plan_affecting_convert (
    ACTION (
        sqlserver.database_name
    )
    WHERE (
        sqlserver.database_name = N'WideWorldImporters'
    )
),
ADD EVENT sqlserver.sql_batch_completed (
    ACTION (
        sqlserver.database_name
    )
    WHERE (
        sqlserver.database_name = N'WideWorldImporters'
    )
),
ADD EVENT sqlserver.sql_batch_starting (
    ACTION (
        sqlserver.database_name
    )
    WHERE (
        sqlserver.database_name = N'WideWorldImporters'))
ADD TARGET package0.event_file (
    SET filename = N'/var/log/ImplicitConversion.xel'
)
WITH (
    MAX_MEMORY=4096 KB,
    EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY=30 SECONDS,
    MAX_EVENT_SIZE=0 KB,
    MEMORY_PARTITION_MODE=NONE,
    TRACK_CAUSALITY=OFF,
    STARTUP_STATE=OFF
)
GO

ALTER EVENT SESSION [ImplicitConversionCapture] 
ON SERVER STATE = START;
GO


SELECT TransactionDate,
       IsFinalized
FROM [Sales].[CustomerTransactions]
where IsFinalized LIKE '1%';


ALTER EVENT SESSION ImplicitConversionCapture
ON SERVER STATE = STOP;
GO

DROP EVENT SESSION ImplicitConversionCapture ON SERVER;
GO

-- Now we shall take a look on results
SELECT --[XMLData],
       [XMLData].value('(/event/@name)[1]','varchar(max)') AS [EventName],
       [XMLData].value('(/event/@timestamp)[1]','DATETIME2') AS [Timestamp],
       [XMLData].value('(/event/data[@name=''batch_text'']/value)[1]','varchar(max)') AS [BatchText],
       [XMLData].value('(/event/data[@name=''expression'']/value)[1]','varchar(max)') AS [Expression],
       [XMLData].value('(/event/data[@name=''convert_issue'']/text)[1]','varchar(max)') AS [ConvertIssue]
FROM (
    SELECT OBJECT_NAME              AS [Event], 
           CONVERT(XML, event_data) AS [XMLData]
    FROM sys.fn_xe_file_target_read_file ('/var/log/ImplicitConversion*.xel',NULL,NULL,NULL)
) as me
WHERE [XMLData].value('(/event/action[@name=''database_name'']/value)[1]','varchar(max)') = N'WideWorldImporters'
ORDER BY [Timestamp];
GO
