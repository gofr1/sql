USE DEMO;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- An explicit transaction to update the [ProductName] for the ID 1 and 2.
BEGIN TRANSACTION;
UPDATE dbo.Products
SET [ProductName] = 'Mac'
WHERE ID IN (1,2);

WAITFOR DELAY '00:00:10';

ROLLBACK TRANSACTION;