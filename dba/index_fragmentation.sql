-- Investigating the fragmented indexes
USE DEMO
GO

SELECT Coalesce(Object_Schema_Name(indexes.object_id) + '.', '')
       + Coalesce(Object_Name(indexes.object_id) + '/', '')
       + Coalesce(indexes.name, 'Heap') as [index_name], 
       STR(avg_fragmentation_in_percent, 10,1) AS [avg_fragmentation_%],
       STR(avg_page_space_used_in_percent, 10,1) AS [avg_page_space_used_%],
       fill_factor,
       STR((avg_record_size_in_bytes * record_count) / (1024.0 * 1024), 10,2) AS [index_size_MB]
FROM sys.dm_db_index_physical_stats(Db_Id(), NULL, NULL, NULL, 'Sampled') AS IPS
INNER JOIN sys.indexes
    ON indexes.index_id = IPS.index_id AND indexes.object_id = IPS.object_id
WHERE ObjectProperty(indexes.object_id, 'IsUserTable') = 1 AND index_level=0 --leaf level
ORDER BY [index_size_MB] DESC
GO