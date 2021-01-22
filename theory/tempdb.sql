--! Functions of tempdb:
--? To act like a page/swap file at the OS level. 
--  If a SQL Server operation is too large to be completed in memory or if the initial memory grant for a query is too small, 
-- the operation can be moved to tempdb.
--? To store temporary tables. 
--  Anyone who has created a temporary table in T-SQL using a pound or hash prefix (#) or the double pound/hash prefix (##) has 
-- created an object in tempdb as this is where those are stored.
--? When a trigger is executing the inserted/deleted virtual tables are stored in tempdb.
--? Any DB that uses RCSI will have their row versioning information stored in tempdb.


--? cannot be restored. 
--? is in SIMPLE recovery and this cannot be changed.
--? cannot be backed up.
--? everyone has access and the same access to the tempdb.


-- tempdb is regenerated/recreated upon every start of the SQL Server instance. 
-- Any objects that have been created in tempdb during a previous session will not persist upon a service restart. 
-- tempdb gets its initial object list from the model database which is generally going to be empty or nearly empty.

--! There should be one tempdb data file for each thread/core/vCPU on the instance with a maximum of 8
USE [master];

ALTER DATABASE tempdb ADD FILE (NAME = N'temp2', FILENAME = N'/var/opt/mssql/data/tempdb2.ndf', SIZE = 8192KB);
ALTER DATABASE tempdb ADD FILE (NAME = N'temp3', FILENAME = N'/var/opt/mssql/data/tempdb3.ndf', SIZE = 8192KB);
ALTER DATABASE tempdb ADD FILE (NAME = N'temp4', FILENAME = N'/var/opt/mssql/data/tempdb4.ndf', SIZE = 8192KB);

-- In the terminal:
-- sudo ls -lah /var/opt/mssql/data/ | grep temp
--* -rw-rw----  1 mssql mssql 8.0M Jan 22 15:47 tempdb2.ndf
--* -rw-rw----  1 mssql mssql 8.0M Jan 22 15:47 tempdb3.ndf
--* -rw-rw----  1 mssql mssql 8.0M Jan 22 15:47 tempdb4.ndf
--* -rw-r-----  1 mssql mssql 8.0M Jan 22 15:47 tempdb.mdf
--* -rw-r-----  1 mssql mssql 8.0M Jan 22 15:48 templog.ldf

--! After resizing/adding/removing files restart SQL Server

-- USE [master];
-- ALTER DATABASE tempdb REMOVE FILE temp2;
-- ALTER DATABASE tempdb REMOVE FILE temp3;
-- ALTER DATABASE tempdb REMOVE FILE temp4;

USE [tempdb];
--! SQL Server tempdb Database Location
-- To get info about tempdb files use:
SELECT *
FROM sys.sysfiles;

SELECT [name], 
       physical_name,
       state_desc
FROM [master].sys.master_files
WHERE database_id = DB_ID(N'tempdb');

--! Moving/Modifying tempdb files
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', FILENAME = N'/var/opt/mssql/data/tempdb.mdf');
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'templog', FILENAME = N'/var/opt/mssql/data/templog.ldf');

--! Run an integrity check is below.
DBCC CHECKDB ('tempdb'); 
