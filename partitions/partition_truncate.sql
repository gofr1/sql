USE DEMO;

SELECT count(*) FROM dbo.IndexTest WHERE Id > 20000 -- It's partition 6, 4568 records

-- Truncate specific partition (available fro, 2016 version)
TRUNCATE TABLE dbo.IndexTest WITH (PARTITIONS (6))

SELECT count(*) FROM dbo.IndexTest WHERE Id > 20000  -- Now it is clear