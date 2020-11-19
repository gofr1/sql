-- Investigating the fragmented indexes
USE DEMO;

--sys.dm_db_index_physical_stats
--avg_fragmentation_in_percent -> Logical fragmentation
-- Logical fragmentation for indexes, or extent fragmentation for heaps in the IN_ROW_DATA allocation unit.
--avg_page_space_used_in_percent -> Internal fragmentation

--? External fragmentation – refers to pages being out of order
--? Internal fragmentation – refers to the empty space on a page

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

--! Columnstore check
--! >= 20% ALTER INDEX REORGANIZE

--? total_rows 
-- Number of rows physical stored in the row group. For compressed row groups, this includes the rows that are marked as deleted.
--? deleted_rows 	
-- Number of rows physically stored in a compressed row group that are marked for deletion. 0 for row groups that are in the delta store.
SELECT i.object_id,
       object_name(i.object_id) table_name,
       i.index_id,
       i.name index_name,
       i.type_desc,
       100*(ISNULL(SUM(c.deleted_rows),0))/NULLIF(SUM(c.total_rows),0) fragmentation
FROM sys.indexes i  
INNER JOIN sys.dm_db_column_store_row_group_physical_stats c
    ON i.object_id = c.object_id AND i.index_id = c.index_id
--WHERE object_name(i.object_id) = 'table_name'
GROUP BY i.object_id, i.index_id, i.name, i.type_desc
ORDER BY object_name(i.object_id), i.name;
