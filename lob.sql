-- LOB_DATA Allocation Units
-- Most data types in SQL Server take up no more than 8000 bytes of storage. 
-- However, there are a few data types, which allow for larger pieces of information to be stored. 
-- Examples include the VARCHAR(MAX), VARBINARY(MAX) or XML data types. 

USE DEMO;

DROP TABLE IF EXISTS dbo.TableWithLob;

CREATE TABLE dbo.TableWithLob (
    id INT IDENTITY(1,1) CONSTRAINT [PK_TableWithLob_id] PRIMARY KEY,
    some_value INT,
    some_lob VARCHAR(MAX)
);

INSERT INTO dbo.TableWithLob(some_value)
VALUES(11),(13),(15),(17),(19);

--Let's check
SELECT OBJECT_SCHEMA_NAME(p.object_id) AS schema_name,
       OBJECT_NAME(p.object_id) AS table_name,
       i.name AS index_name,
       p.partition_number,
       p.rows,
       au.allocation_unit_id,
       au.type_desc AS allocation_unit_type,
       au.used_pages,
       au.data_pages,
       au.total_pages
FROM sys.allocation_units au
INNER JOIN sys.partitions p
    ON p.partition_id = au.container_id
INNER JOIN sys.indexes i
    ON p.index_id = i.index_id AND p.object_id = i.object_id
WHERE p.object_id = OBJECT_ID('dbo.TableWithLob');
--The first one is the IN_ROW_DATA allocation unit that is part of every table. 
--The second is an allocation unit of type LOB_DATA. 
--That allocation unit does not have any pages allocated to it yet, 
--as all rows in the table have their some_lob column set to NULL.

UPDATE dbo.TableWithLob
SET some_lob = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod'+
'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostr'+
'ud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irur'+
'e dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur'+
'. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mo'+
'llit anim id est laborum.'
WHERE some_value in (11, 13, 15, 17, 19);


--Once there is actual LOB data to store, it will get stored in that additional allocation unit in special pages. 
--Those pages that hold the LOB values are pages of type 3. They are called TEXT MIX pages or just LOB pages. 
--To confirm that, let us first look at the pages that belong to the example table in its current state. 
--We can use the following query to get a list of all pages in our table:
SELECT OBJECT_SCHEMA_NAME(p.object_id) AS schema_name,
       OBJECT_NAME(p.object_id) AS table_name,
       i.name AS index_name,
       p.partition_number,
       dddpa.allocation_unit_id,
       dddpa.allocation_unit_type_desc,
       dddpa.allocated_page_file_id AS file_id,
       dddpa.allocated_page_page_id AS page_id,
       dddpa.page_type,
       dddpa.page_type_desc,
       dddpa.page_level
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('dbo.TableWithLob'), NULL, NULL, 'DETAILED') dddpa
INNER JOIN sys.allocation_units au
    ON dddpa.allocation_unit_id = au.allocation_unit_id
INNER JOIN sys.partitions p
    ON p.partition_id = au.container_id
INNER JOIN sys.indexes i
    ON p.index_id = i.index_id AND p.object_id = i.object_id
ORDER BY dddpa.allocation_unit_id, dddpa.allocated_page_file_id, dddpa.allocated_page_page_id;
--One is a normal data page and the other one is an IAM page that is used by 
--SQL Server to keep track of all pages that belong to this allocation unit. 

UPDATE dbo.TableWithLob 
SET some_lob = REPLICATE(CAST('X' AS VARCHAR(MAX)),8001)
WHERE id = 5;

--The table now consists of four pages: The two pages that were there before, but also two new pages. 
--Both new pages are in the LOB_DATA allocation unit. SQL Server needs at least one IAM page in every 
--allocation unit, to catalog the pages that are part of it. Therefore, one of the new pages is an 
--IAM page. The other page is, as we expected, a TEXT_MIX_PAGE. 