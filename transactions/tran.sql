USE AdventureWorks2012;

BEGIN TRANSACTION;

UPDATE Person.Person
SET Title = 'Mr.'
WHERE BusinessEntityId = 307;

COMMIT TRANSACTION;