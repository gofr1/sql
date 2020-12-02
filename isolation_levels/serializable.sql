--When selecting some records with this isolation level
--special Key Range Locking is used which protects this records from
--been deleted, inserted, updated within the selected range
--Prevents so called Phantom records read

USE AdventureWorks2012;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

--If you launch insert statement from start_tran.sql
--You will get RangeI-N for that session in dm_tran_locks
--The current session will use RangeS-S lock
SELECT *
FROM Person.Address
WHERE StateProvinceID BETWEEN 10 AND 12

COMMIT TRANSACTION;
