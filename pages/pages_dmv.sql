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
SELECT [name],
       CASE WHEN index_id = 0 THEN 'heap'
            WHEN index_id = 1 THEN 'clustered index'
            WHEN index_id >= 2 THEN 'nonclustered index'
        END as [index],
       COUNT(*) cached_pages_count
FROM sys.dm_os_buffer_descriptors AS bd   
INNER JOIN (  
    SELECT object_name(p.object_id) AS [name],
           p.index_id,
           au.allocation_unit_id
    FROM sys.allocation_units AS au  
    INNER JOIN sys.partitions AS p   
        ON au.container_id = p.hobt_id 
        --Indicates the ID of the data heap or B-tree (HoBT) that contains the rows for this partition
           AND (au.type = 1 OR au.type = 3) 
    UNION ALL  
    SELECT object_name(p.object_id) AS [name],
           p.index_id, 
           au.allocation_unit_id  
    FROM sys.allocation_units AS au  
    INNER JOIN sys.partitions AS p   
        ON au.container_id = p.partition_id AND au.type = 2  
) AS obj   
    ON bd.allocation_unit_id = obj.allocation_unit_id  
WHERE database_id = DB_ID()  
GROUP BY [name], index_id   
ORDER BY cached_pages_count DESC; 

--Select from one table and run the query above once again
SELECT * 
FROM dbo.IndexTest;