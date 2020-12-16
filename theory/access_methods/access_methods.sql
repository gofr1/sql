USE DEMO;

SET STATISTICS PROFILE, XML, TIME, IO ON;


--! Seek
-- A seek is an efficient access method that can be fulfilled using an index structure. 
-- Seeking touches fewer pages than scanning, and can only occur on an index of some type. 
SELECT *
FROM dbo.IndexTest
WHERE id = 15000
--* PhysicalOp="Clustered Index Seek" LogicalOp="Clustered Index Seek"

--! Scan
-- A scan is basically an access method whereby all data, or some range of data, 
-- in an index or heap must be touched or retrieved in order to fulfill a request. 
SELECT *
FROM dbo.IndexTest
--* PhysicalOp="Index Scan" LogicalOp="Index Scan"


--! Singleton Lookup (Key for indexed table, RID for Heap)
-- A singleton lookup is a seek operation whereby a single record/page of data is retrieved. 
-- This can occur for example when you perform a query that needs to access only a single record, 
-- or a few records from a single page. 

--! Full Scan - key ordered
-- A key-ordered full scan is a scan operation whereby all the leaf pages of a given B-tree 
-- structure are retrieved by following the page linkage (i.e. starting with the first page 
-- in the leaf level and following to the next page via the doubly-linked list, and so on and 
-- so on). Note that this type of scan can only be performed on a B-tree structure and 
-- NOT against a heap. This occurs for example when you perform a query that must return all 
-- the rows and columns in a clustered table, or only a few rows but the filter predicate has 
-- no index to seek with, or against a non-clustered index if you want all rows for a table 
-- but only values from columns that are covered by the non-clustered index.

--! Range Scan
-- A range-scan is a scan operation whereby a range of pages are retrieved - think of this as 
-- a full-scan with boundaries.

--! Read-Ahead
-- Read-ahead is an access method mechanism that attempts to intelligently pre-fetch data that 
-- resides on-disk into the data cache prior to it being needed for use by the CPU - this is 
-- done to try and optimize the IO throughput of a system in order to keep the CPU as busy as 
-- possible without waiting on the slower IO system to get needed data. This type of operation 
-- is typically reserved for scans of data that fetch medium/large amounts of pages/data, 
-- and can issue 1,8,32, or 64 page IOs in a single IO operation - the size of operation that 
-- can be performed is very heavily impacted by the contiguity of the data (the more contiguous 
-- the data, the bigger the IOs that can performed, the better performance you see). 
-- There are 2 kinds of read-ahead operations:
--     1 that works with allocation ordered scans
--     2 that works with key-ordered scans. 

SET STATISTICS PROFILE, XML, TIME, IO OFF;