USE DEMO;

DROP TABLE IF EXISTS dbo.HeapTable;

CREATE TABLE dbo.HeapTable (
    Col1 VARCHAR(2000),
    Col2 VARCHAR(2000),
    Col3 VARCHAR(2000)
);

INSERT INTO dbo.HeapTable (Col1, Col2, Col3) VALUES
(REPLICATE('a', 2000), '', ''),
(REPLICATE('b', 2000), '', ''),
(REPLICATE('c', 2000), '', ''),
(REPLICATE('d', 2000), '', '');
--Go check forwarding records (No such)

UPDATE dbo.HeapTable 
SET Col2 = REPLICATE('e', 2000);
--Go check forwarding records (Two)

UPDATE dbo.HeapTable 
SET Col3 = REPLICATE('f', 2000);
--Go check forwarding records (Three)

--Rebuild table to fix this
ALTER TABLE dbo.HeapTable REBUILD;
--Go check forwarding records (No such)

--Check forwarding records here
SELECT OBJECT_NAME(object_id) as table_name,
       index_type_desc,
       alloc_unit_type_desc,
       avg_page_space_used_in_percent,
       page_count,
       record_count,
       min_record_size_in_bytes,
       max_record_size_in_bytes,
       forwarded_record_count
FROM sys.dm_db_index_physical_stats (DB_ID(N'DEMO'), OBJECT_ID(N'dbo.HeapTable'), NULL, NULL , 'DETAILED');

