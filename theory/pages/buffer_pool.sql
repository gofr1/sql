--*Buffer pool is a cache of SQL Server

--*Some operator form our execution plan requests a page from buffer pool
--*If the page is in buffer pool it is retrieved immediately (logical read)

--*If the page is not in buffer pool it send async request to Storage,
--*storage returns a page to buffer pool (it is now in-memory) and buffer pool
--*returns the page to query (physical read)

USE [master];

--Returns information about all the data pages that are currently in the SQL Server buffer pool
SELECT *
FROM sys.dm_os_buffer_descriptors;

--The following query returns you, how much space is wasted by every database on your SQL Server instance
--and the count of pages loaded for each database
SELECT CASE database_id WHEN 32767 THEN 'ResourceDb' ELSE db_name(database_id) END db_name,
       SUM(free_space_in_bytes) / 1024.0 free_kb,
       COUNT(*) cached_pages_count,
       COUNT(*) * 8 cached_pages_size_kb
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY SUM(free_space_in_bytes) DESC;

USE DEMO;

--If you there was no queries on your database you will see only system objects
SELECT t.[name],
       CASE WHEN obj.index_id = 0 THEN 'heap'
            WHEN obj.index_id = 1 THEN 'clustered index'
            WHEN obj.index_id >= 2 THEN 'nonclustered index'
        END as [index],
       COUNT(*) cached_pages_count,
       COUNT(*) * 8192 / 1024.0 used_kb -- Page count * page size / 1024 (bytes in kb)
FROM sys.dm_os_buffer_descriptors AS bd   
INNER JOIN (  
    SELECT p.object_id,
           p.index_id,
           au.allocation_unit_id
    FROM sys.allocation_units AS au  
    INNER JOIN sys.partitions AS p   
        ON au.container_id = p.hobt_id 
        --Indicates the ID of the data heap or B-tree (HoBT) that contains the rows for this partition
           AND (au.type = 1 OR au.type = 3) 
    UNION ALL  
    SELECT p.object_id,
           p.index_id, 
           au.allocation_unit_id  
    FROM sys.allocation_units AS au  
    INNER JOIN sys.partitions AS p   
        ON au.container_id = p.partition_id 
        --Indicates the partition ID.
        AND au.type = 2  
) AS obj   
    ON bd.allocation_unit_id = obj.allocation_unit_id
INNER JOIN sys.tables t 
    ON t.object_id = obj.object_id
WHERE database_id = DB_ID() -- In current database
    AND t.is_ms_shipped = 0 --To exclude system tables
GROUP BY t.[name], obj.index_id   
ORDER BY cached_pages_count DESC; 

--Select from one table and run the query above once again
SELECT * 
FROM dbo.IndexTest;