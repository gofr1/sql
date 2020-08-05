USE DEMO;

--Get the list of partitioned tables
SELECT DISTINCT t.name as TableName
FROM sys.partitions p
INNER JOIN sys.tables t
ON p.object_id = t.object_id
WHERE p.partition_number <> 1;

--Get some  information regarding partitions
SELECT ps.Name AS PartitionScheme, 
       pf.name AS PartitionFunction,
       fg.name AS FileGroupName,
       p.rows, 
       prv.value AS PartitionFunctionValue,fg.data_space_id
FROM sys.indexes i 
INNER JOIN sys.partitions p 
    ON i.object_id=p.object_id AND i.index_id=p.index_id 
INNER JOIN sys.partition_schemes ps 
    ON ps.data_space_id = i.data_space_id 
INNER JOIN sys.partition_functions pf 
    ON pf.function_id = ps.function_id 
LEFT JOIN sys.partition_range_values prv 
    ON prv.function_id = pf.function_id AND prv.boundary_id = p.partition_number
INNER JOIN sys.allocation_units au 
    ON au.container_id = p.hobt_id  
INNER JOIN sys.filegroups fg 
    ON fg.data_space_id = au.data_space_id 
--WHERE i.object_id = object_id('Partitioned Table Name'));