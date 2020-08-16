USE DEMO;

-- DBCC IND ( { 'dbname' | dbid }, { 'objname' | objid }, { nonclustered indid | 1 | 0 | -1 | -2 });
-- nonclustered indid = non-clustered Index ID
-- 1 = Clustered Index ID
-- 0 = Displays information in-row data pages and in-row IAM pages (from Heap)
-- -1 = Displays information for all pages of all indexes including LOB (Large object binary) pages and row-overflow pages
-- -2 = Displays information for all IAM pages

--Show pages ids that are used by specific table
DBCC IND ('DEMO', IndexTest, -1);

--Check trace 3604 status
DBCC TRACESTATUS (3604);  

-- dbcc page ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ]);Printopt:
-- 0 - print just the page header
-- 1 - page header plus per-row hex dumps and a dump of the page slot array 
-- 2 - page header plus whole page hex dump
-- 3 - page header plus detailed per-row interpretation

--Trace on and get page info
DBCC TRACEON (3604);
DBCC PAGE ('DEMO', 1, 498, 1);
DBCC TRACEOFF (3604);