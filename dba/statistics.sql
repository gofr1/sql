--!20% + 500 rows changes will update statistics

USE [master];

ALTER DATABASE [DEMO] 
SET auto_create_statistics ON;

ALTER DATABASE [DEMO] 
SET auto_update_statistics ON WITH no_wait;

--Check if update statistics is enabled
SELECT [name], 
       CASE WHEN is_auto_create_stats_on = 1 THEN 'Enabled' ELSE 'Disabled' END AS 'Auto Create Statistics', 
       CASE WHEN is_auto_update_stats_on = 1 THEN 'Enabled' ELSE 'Disabled' END AS 'Auto Update Statistics' 
FROM sys.databases 
WHERE database_id > 4 --not system databases

USE DEMO;

--Stats_ID: It is the unique ID of the statistics object
--Name: It is the statistics name
--Last_updated: It is the date and time of the last statistics update
--Rows: It shows the total number of rows at the time of the last statistics update
--Rows_sampled: It gives the total number of sample rows for the statistics
--Unfiltered_rows: In the screenshot, you can see both rows_sampled and unfiltered_rows value the same because we did not use any filter in the statistics
--Modification_counter: It is a vital column to look. We get the total number of modifications since the last statistics update

SELECT sp.stats_id, 
       t.[name],
       s.[name], 
       s.filter_definition, 
       sp.last_updated, 
       sp.rows, 
       sp.rows_sampled, 
       sp.steps, 
       sp.unfiltered_rows, 
       sp.modification_counter
FROM sys.stats AS s
INNER JOIN sys.tables t 
    ON t.object_id = s.object_id
CROSS APPLY sys.dm_db_stats_properties(s.[object_id], s.stats_id) AS sp
WHERE s.[object_id] = OBJECT_ID('dbo.IndexTest')
--and s.[name] like '_WA%' -- to filter autocreated statistics
;

--Statistics update
UPDATE STATISTICS dbo.IndexTest;--for table
UPDATE STATISTICS dbo.IndexTest PK_IndexTest_id; --for specific index

--If we want mandatory FULL SCAN we can use 
UPDATE STATISTICS dbo.IndexTest PK_IndexTest_id WITH FULLSCAN;
--OR
UPDATE STATISTICS dbo.IndexTest PK_IndexTest_id WITH SAMPLE 100 PERCENT;

--By default columns statistics is not updated
UPDATE STATISTICS dbo.IndexTest PK_IndexTest_id WITH FULLSCAN, COLUMNS;

--To update statistics for all tables
EXEC sp_updatestats

DBCC SHOW_STATISTICS('dbo.IndexTest', 'PK_IndexTest_id') WITH STAT_HEADER;  -- or _WA if you need autogenerated
EXEC Sp_helpstats 'PK_IndexTest_id'

--Incremental statistics
--Check if enabled
SELECT i.name AS Index_name,
	   i.Type_Desc AS Type_Desc,
	   ds.name AS DataSpaceName,
	   ds.type_desc AS DataSpaceTypeDesc,
	   st.is_incremental
FROM sys.objects AS o
JOIN sys.indexes AS i 
    ON o.object_id = i.object_id
JOIN sys.data_spaces ds 
    ON ds.data_space_id = i.data_space_id
JOIN sys.stats st
    ON st.object_id = o.object_id AND st.name = i.name
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s 
    ON i.object_id = s.object_id 
AND i.index_id = s.index_id AND s.database_id = DB_ID()
WHERE o.type = 'U'
  AND i.type <= 2
  AND o.object_id = OBJECT_ID('dbo.IndexTest')

--Enabling Incremental Statistics for database
USE [master];
ALTER DATABASE [DEMO] SET AUTO_CREATE_STATISTICS ON (INCREMENTAL = ON);

USE DEMO;
--
UPDATE STATISTICS DEMO.dbo.IndexTest 
(PK_IndexTest_id) WITH INCREMENTAL = ON;

--Update statistics on partition
UPDATE STATISTICS DEMO.dbo.IndexTest 
(PK_IndexTest_id) WITH RESAMPLE ON PARTITIONS(1,5); -- with range of partitions
-- could be checked in sys.partitions for current table

--Check if incremental statistics is collected for an object
SELECT OBJECT_NAME([object_id]) table_name,
       [name] index_name,
       is_incremental,
       stats_id
FROM sys.stats
WHERE name = 'PK_IndexTest_id';
