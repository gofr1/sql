USE [master];
--Just in case get the session_id
SELECT @@SPID session_id

--For RCSI
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

--For SNAPSHOT ISOLATION
USE DEMO;

BEGIN TRANSACTION;

UPDATE dbo.Emails
SET Email = 'address@example.com'
WHERE Id = 3

COMMIT TRANSACTION;

ROLLBACK TRANSACTION;

-------------------------------
--Rollback script for changes Above
UPDATE AdventureWorks2012.Person.Person
SET Title = 'Mr.'
WHERE BusinessEntityId = 307;

DELETE FROM AdventureWorks2012.Person.Address
WHERE StateProvinceID = 11 AND AddressLine1 = ''

UPDATE DEMO.dbo.Emails
SET Email = 'email@example.com'
WHERE Id = 3