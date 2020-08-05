USE DEMO;

--Show pages ids that are used by specific table
DBCC IND ('DEMO', IndexTest, -1);

--Check trace 3604 status
DBCC TRACESTATUS (3604);  

--Trace on and get page info
DBCC TRACEON (3604);
DBCC PAGE ('DEMO', 1, 498, 1);
DBCC TRACEOFF (3604);