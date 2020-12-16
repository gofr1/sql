USE AdventureWorks2012;

--The REPEATABLE READ allows you to read the same data repeatedly and it makes sure that 
--any transaction cannot update this data until you complete your reading.

--Readers blocks the writers in this isolation level
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;

SELECT *
FROM Person.Person
WHERE ModifiedDate = '2015-04-15 16:33:33.123';

--Launch first part of this query and then launch start_tran.sql (w/o COMMIT part)

--In dm_tran_locks you will see waiting for exclusive lock:
--*resource_type resource_database_id resource_description resource_associated_entity_id request_mode request_type request_status
--*KEY           8                    (9ef0df41acbb)       72057594045595648             S            LOCK         GRANT
--*KEY           8                    (9ef0df41acbb)       72057594045595648             X            LOCK         WAIT

COMMIT TRANSACTION;
--After commiting eXclusive lock will be acquired 