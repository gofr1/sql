-- Investigating the fragmented indexes
USE DEMO;

--sys.dm_db_index_physical_stats
--avg_fragmentation_in_percent -> Logical fragmentation
--avg_page_space_used_in_percent -> Internal fragmentation

--!Reorganize when fragmentation 5-30%
--!Rebuild when fragmentation > 30%
--!AND there should be >10000 pages on leaf level

SELECT COALESCE(OBJECT_SCHEMA_NAME(i.object_id) + '.', '') +
       COALESCE(OBJECT_NAME(i.object_id) + '/', '') +
       COALESCE(i.name, 'Heap') as [index_name_type], 
       ps.partition_number,
       STR(ps.avg_fragmentation_in_percent, 10,1) AS [avg_fragmentation_%],
       STR(ps.avg_page_space_used_in_percent, 10,1) AS [avg_page_space_used_%],
       ps.page_count,
       ps.index_id,
       ps.index_type_desc,
       i.fill_factor,
       STR((ps.avg_record_size_in_bytes * ps.record_count) / (1024.0 * 1024), 10,2) AS [index_size_MB]
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'Sampled') AS ps
INNER JOIN sys.indexes i
    ON i.index_id = ps.index_id AND i.object_id = ps.object_id
WHERE ObjectProperty(i.object_id, 'IsUserTable') = 1 AND ps.index_level = 0 --leaf level
ORDER BY [index_name_type] ASC, partition_number ASC;

USE DEMO;
--*REORGANIZE
--Is running through pages, switch the first one with n-page >= n+1-page several times step by step
--to get all pages in order.
ALTER INDEX ALL ON dbo.IndexTest REORGANIZE; 
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REORGANIZE;
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REORGANIZE PARTITION = 1;

--*REBUILD
--When you rebuild index you need additional space in transaction log and in storage
--because in some point of time old and new data structures live together until old structure 
--gets deallocated.
--Rebuild is one big transaction. 
ALTER INDEX ALL ON dbo.IndexTest REBUILD WITH (ONLINE=ON);
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REBUILD WITH (ONLINE=ON);
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REBUILD PARTITION = 1;