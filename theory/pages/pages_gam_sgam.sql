USE DEMO;

-- Uniform Extent: These are the extents owned by single user objects. 
-- All 8 pages of these extents can be used by a single object, the owning object.

-- Mixed Extent:These are the extents owned by multiple user objects. 
-- There is a  possibility of each page in this  extent, that might be allocated 
-- to 8 different user objects. Each of the eight pages in the extent can be 
-- owned by  different objects.

--To make space allocation more optimize, SQL server will not allocate 
--pages from uniform extent to a table or index if its size is less than 8 pages. 

--If you see that 8 pages in a row with same IAMPID and have no gaps - it is a uniform extent
--If not -they are from Mixed extent 
DBCC IND('DEMO','IndexTest',1);

-- GAM(Global Allocation Map): GAM pages records what extents have been allocated 
-- for any use. GAM has bit for every extent. If the bit is 1, the corresponding extent 
-- is free, if the bit is 0, the corresponding extent is in use as uniform or mixed extent.
-- A GAM page can hold information of around 64000 extents. That is, a GAM page can 
-- hold information of (64000X8X8)/1024 = 4000 MB approximately. In short, 
-- a data file of size 7 GB will have two GAM pages.

-- SGAM (Shares Global Allocation Map): SGAM pages record what extents are currently 
-- being used as mixed extent and also have at least one unused page. 
-- SGAM has bit for every extent. If the bit is 1, the corresponding extent is used 
-- as a mixed extent and has at least one page free to allocate. If the bit is 0, 
-- the extent is either not used as a mixed extent or it is mixed extent and with 
-- all its pages being used. A SGAM page can hold information of 64000 extents. 
-- That is, a SGAM page can hold information of (64000X8X8)/1024 = 4000 MB. 
-- In short, a data file of size 7 GB will have two SGAM page.

-- In any data file, the third page(page no 2) is GAM and fourth page (page no 3) 
-- is SGAM page. The first page (page no 0) is file header and second page (page no 1) 
-- is PFS (Page Free Space) page.  

--We can see the GAM and SGAM pages using DBCC page command. Refer earlier post for the usage of DBCC page 

--Check trace 3604 status
DBCC TRACESTATUS (3604);  

--GAM
DBCC TRACEON (3604);
DBCC PAGE ('DEMO', 1, 2, 3);
DBCC TRACEOFF (3604);

--SGAM
DBCC TRACEON (3604);
DBCC PAGE ('DEMO',1, 3, 3)
DBCC TRACEOFF (3604);
