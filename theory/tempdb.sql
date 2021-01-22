--! Functions of tempdb:
--? To act like a page/swap file at the OS level. 
--  If a SQL Server operation is too large to be completed in memory or if the initial memory grant for a query is too small, 
-- the operation can be moved to tempdb.
--? To store temporary tables. 
--  Anyone who has created a temporary table in T-SQL using a pound or hash prefix (#) or the double pound/hash prefix (##) has 
-- created an object in tempdb as this is where those are stored.
--? When a trigger is executing the inserted/deleted virtual tables are stored in tempdb.
--? Any DB that uses RCSI will have their row versioning information stored in tempdb.

-- tempdb is regenerated/recreated upon every start of the SQL Server instance. 
-- Any objects that have been created in tempdb during a previous session will not persist upon a service restart. 
-- tempdb gets its initial object list from the model database which is generally going to be empty or nearly empty.


