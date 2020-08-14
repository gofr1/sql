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
    ON o.[object_id] = c.id

