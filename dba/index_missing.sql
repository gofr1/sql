USE [AdventureWorks2017]
GO

--Get a list of the indexes that have been used and how they are being used
SELECT  DB_NAME(u.database_id) AS [database_name], 
        SCHEMA_NAME(o.[schema_id]) AS [schema_name], 
        OBJECT_NAME(u.[object_id]) AS [table_name], 
        (SELECT [name] 
         FROM sys.indexes i 
         WHERE i.[object_id] = u.[object_id] AND i.[index_id] = u.[index_id]) as [index_name], 
        u.user_seeks, 
        u.user_scans, 
        u.user_lookups, 
        u.user_updates 
FROM sys.dm_db_index_usage_stats u
INNER JOIN sys.objects o
    ON u.[object_id] = o.[object_id] 
WHERE u.database_id = DB_ID(DB_NAME()) AND o.[type] = 'U'
GO

--List each user table and all of the tables indexes that have not been used in query above
SELECT DB_NAME() AS [database_name], 
       SCHEMA_NAME(o.[schema_id]) AS [schema_name], 
       OBJECT_NAME(o.[object_id]) AS [table_name], 
       i.[name] AS [index_name], 
       i.[index_id] 
FROM sys.objects o
INNER JOIN sys.indexes i
    ON i.[object_id] = o.[object_id]
WHERE NOT EXISTS (
    SELECT * 
    FROM sys.dm_db_index_usage_stats u
    WHERE u.database_id = DB_ID(DB_NAME())
    AND i.[object_id] = u.[object_id]  
    AND i.[index_id] = u.[index_id]
    ) AND o.[type] = 'U' 
ORDER BY [database_name], [schema_name], [table_name]
GO

--List each user table, all of its indexes and the columns that make up the index
SELECT SCHEMA_NAME(o.[schema_id]) AS [schema_name], 
       o.[name] AS [table_name], 
       i.[name] AS [index_name], 
       ic.key_ordinal, 
       c.[name] 
FROM sys.objects o
INNER JOIN sys.indexes i
    ON o.[object_id] = i.[object_id] 
INNER JOIN sys.index_columns ic
    ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id] 
INNER JOIN sys.columns c
    ON ic.[object_id] = c.[object_id] AND ic.[column_id] = c.[column_id] 
WHERE o.[type] = 'U' 
ORDER BY [schema_name], [table_name], [index_name], ic.key_ordinal 
GO

--The query below allows you to see all indexes to compare both used and unused indexes since the stats were collected
SELECT pvt.[schema_name], 
       pvt.[table_name], 
       pvt.[index_name], 
       pvt.[index_id], 
       [1] AS COL1, 
       [2] AS COL2, 
       [3] AS COL3, 
       [4] AS COL4,  
       [5] AS COL5, 
       [6] AS COL6, 
       [7] AS COL7, 
       u.user_seeks, 
       u.user_scans, 
       u.user_lookups
FROM (
    SELECT SCHEMA_NAME(o.[schema_id]) AS [schema_name], 
           o.[name] AS [table_name], 
           i.[name] AS [index_name], 
           i.[index_id],
           ic.key_ordinal, 
           c.[name] as [column_name],
           o.[object_id]
    FROM sys.objects o
    INNER JOIN sys.indexes i
        ON o.[object_id] = i.[object_id] 
    INNER JOIN sys.index_columns ic
        ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id] 
    INNER JOIN sys.columns c
        ON ic.[object_id] = c.[object_id] AND ic.[column_id] = c.[column_id] 
    WHERE o.[type] = 'U') p
PIVOT (
        MIN([column_name]) 
        FOR key_ordinal IN ([1],[2],[3],[4],[5],[6],[7])
    ) AS pvt 
INNER JOIN sys.dm_db_index_usage_stats u 
    ON pvt.[object_id] = u.[object_id] AND pvt.[index_id] = u.[index_id] AND u.[database_id] = DB_ID(DB_NAME()) 
UNION  
SELECT pvt.[schema_name], 
       pvt.[table_name], 
       pvt.[index_name], 
       pvt.[index_id], 
       [1] AS COL1, 
       [2] AS COL2, 
       [3] AS COL3, 
       [4] AS COL4,  
       [5] AS COL5, 
       [6] AS COL6, 
       [7] AS COL7, 
       NULL AS user_seeks, 
       NULL AS user_scans, 
       NULL AS user_lookups
FROM (
    SELECT SCHEMA_NAME(o.[schema_id]) AS [schema_name], 
           o.[name] AS [table_name], 
           i.[name] AS [index_name], 
           i.[index_id],
           ic.key_ordinal, 
           c.[name] as [column_name],
           o.[object_id]
    FROM sys.objects o
    INNER JOIN sys.indexes i
        ON o.[object_id] = i.[object_id] 
    INNER JOIN sys.index_columns ic
        ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id] 
    INNER JOIN sys.columns c
        ON ic.[object_id] = c.[object_id] AND ic.[column_id] = c.[column_id] 
    WHERE o.[type] = 'U') p
PIVOT (
        MIN([column_name]) 
        FOR key_ordinal IN ([1],[2],[3],[4],[5],[6],[7])
    ) AS pvt 
WHERE NOT EXISTS (
        SELECT u.[object_id], 
               u.[index_id] 
        FROM sys.dm_db_index_usage_stats u  
        WHERE  pvt.[object_id] = u.[object_id] AND pvt.[index_id] = u.[index_id] AND u.[database_id] = DB_ID(DB_NAME())
    ) 
ORDER BY [schema_name], [table_name], [index_id]
GO