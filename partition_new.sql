USE [master];

--This script can be made with dynamic sql to automate new partition creation
IF NOT EXISTS(SELECT 1 FROM DEMO.sys.filegroups WHERE name = 'test6fg')
ALTER DATABASE DEMO ADD FileGroup test6fg;

IF NOT EXISTS(SELECT 1 FROM DEMO.sys.database_files WHERE name = 'test6dat1')
ALTER DATABASE DEMO 
ADD FILE 
(
    NAME = test6dat1, 
    FILENAME = '/var/opt/mssql/data/t6dat1.ndf', 
    SIZE = 5MB, 
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB 
)
TO FILEGROUP test6fg;

USE DEMO;

ALTER PARTITION SCHEME PS5000 NEXT USED test6fg;
ALTER PARTITION FUNCTION PFdemo() SPLIT RANGE (20000);


SELECT ps.Name AS PartitionScheme, 
       pf.name AS PartitionFunction,
       fg.name AS FileGroupName,
       i.name AS IndexName,
       p.rows, 
       prv.value AS PartitionFunctionValue,
       p.partition_number as PartitionNumber
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