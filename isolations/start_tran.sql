USE [master];
--Just in case get the session_id
SELECT @@SPID session_id

--For SNAPSHOT ISOLATION
USE SSIsoTest;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

UPDATE TestSnapshot SET valueCol = 22 WHERE ID = 1;

COMMIT TRANSACTION;

--For REPEATABLE READ and 
--READ UNCOMMITTED
USE AdventureWorks2012;

BEGIN TRANSACTION;

UPDATE Person.Person
SET Title = 'Mr..'
WHERE BusinessEntityId = 307;

COMMIT TRANSACTION;

ROLLBACK TRANSACTION;

--For SERIALIZABLE
USE AdventureWorks2012;

BEGIN TRANSACTION;

INSERT INTO Person.Address (	
    [AddressLine1],
	[AddressLine2],
	[City],
	[StateProvinceID],
	[PostalCode],
	[SpatialLocation],
	[ModifiedDate]
) VALUES (
    '',
    NULL,
    '',
    11,
    '',
    NULL,
    CURRENT_TIMESTAMP
);

COMMIT TRANSACTION;

ROLLBACK TRANSACTION;
-------------------------------
--Rollback script for changes Above
UPDATE Person.Person
SET Title = 'Mr.'
WHERE BusinessEntityId = 307;

DELETE FROM Person.Address
WHERE StateProvinceID = 11 AND AddressLine1 = ''