USE DEMO;

--Contains entries for each view, rule, default, trigger, CHECK constraint, DEFAULT constraint, 
--and stored procedure within the database. The text column contains the original SQL definition statements
SELECT OBJECT_SCHEMA_NAME(o.object_id) as schema_name,
       OBJECT_NAME(o.object_id) as object_name,
       o.type_desc,
       c.encrypted,
       c.text as script_text
FROM sys.objects o 
INNER JOIN sys.syscomments c 
    ON o.[object_id] = c.id;

--Table definition
SELECT OBJECT_SCHEMA_NAME(t.object_id) as schema_name,
       OBJECT_NAME(t.object_id) as object_name,
       c.name as column_name,
       ty.name as type_name,
       CASE WHEN ty.name IN ('nvarchar', 'nchar') THEN CONCAT('(', c.max_length/2, ')')
            WHEN ty.name IN ('decimal', 'numeric') THEN CONCAT('(', c.[precision], ',', c.scale, ')')
            WHEN ty.name IN ('varchar','char') THEN CONCAT('(', IIF(c.max_length = -1, 'max' ,LTRIM(STR(c.max_length))), ')')
            ELSE '' END as size,
        CASE WHEN c.is_nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END as is_null
        ,t.type
FROM sys.tables t 
INNER JOIN sys.columns c 
    ON t.object_id = c.object_id
INNER JOIN sys.types ty 
    ON c.system_type_id = ty.system_type_id
WHERE t.[type] = 'U';
