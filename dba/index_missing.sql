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