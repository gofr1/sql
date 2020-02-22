-- Space used by tables
SELECT t.[Name] TableName,
       s.[Name] SchemaName,
       p.[Rows] RowCnt,
       SUM(a.total_pages) * 8 TotalSpaceKB,
       SUM(a.used_pages) * 8 UsedSpaceKB,
       (SUM(a.total_pages) - SUM(a.used_pages)) * 8 UnusedSpaceKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.[Name] LIKE '%'
  AND t.is_ms_shipped = 0
  AND i.object_id > 255
GROUP BY t.[Name], s.[Name], p.[Rows]
ORDER BY t.[Name]

--Space used by indexes
SELECT OBJECT_NAME(i.object_id) TableName,
       i.[name] IndexName,
       i.index_id IndexID,
       8 * SUM(a.used_pages) IndexSizeKB
FROM sys.indexes AS i
INNER JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY i.object_id, i.index_id, i.[name]
ORDER BY TableName, IndexName

-- Another way
EXEC sp_spaceused N'{dbo}.{table_name}'