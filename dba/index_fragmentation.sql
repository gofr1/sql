-- Investigating the fragmented indexes
USE DEMO;

--sys.dm_db_index_physical_stats
--avg_fragmentation_in_percent -> Logical fragmentation
--avg_page_space_used_in_percent -> Internal fragmentation

--Reorganize when fragmentation > 5-10%
--Rebuild when fragmentation > 30%

SELECT COALESCE(OBJECT_SCHEMA_NAME(i.object_id) + '.', '') +
       COALESCE(OBJECT_NAME(i.object_id) + '/', '') +
       COALESCE(i.name, 'Heap') as [index_name_type], 
       ps.partition_number,
       STR(ps.avg_fragmentation_in_percent, 10,1) AS [avg_fragmentation_%],
       STR(ps.avg_page_space_used_in_percent, 10,1) AS [avg_page_space_used_%],
       i.fill_factor,
       STR((ps.avg_record_size_in_bytes * ps.record_count) / (1024.0 * 1024), 10,2) AS [index_size_MB]
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'Sampled') AS ps
INNER JOIN sys.indexes i
    ON i.index_id = ps.index_id AND i.object_id = ps.object_id
WHERE ObjectProperty(i.object_id, 'IsUserTable') = 1 AND ps.index_level = 0 --leaf level
ORDER BY [index_name_type] ASC, partition_number ASC;

USE DEMO;
--Reorganize
ALTER INDEX ALL ON dbo.IndexTest REORGANIZE; 
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REORGANIZE;
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REORGANIZE PARTITION = 1;

--Rebuild
ALTER INDEX ALL ON dbo.IndexTest REBUILD WITH (ONLINE=ON);
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REBUILD WITH (ONLINE=ON);
ALTER INDEX PK_IndexTest_id ON dbo.IndexTest REBUILD PARTITION = 1;