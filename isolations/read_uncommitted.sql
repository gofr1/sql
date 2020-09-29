USE AdventureWorks2012;
--Read Uncommitted don't acquire shared lock for reader
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--If transaction from start_tran.sql is rollbacked we have dirty read
SELECT *
FROM Person.Person
WHERE BusinessEntityId = 307;