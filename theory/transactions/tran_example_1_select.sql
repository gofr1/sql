USE DEMO;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

SELECT p.FirstName, 
       s.Name,
       wl.PersonId,
       wl.StuffId
FROM dbo.Wishlist wl 
inner join dbo.Person p 
   ON p.Id = wl.PersonId 
INNER JOIN dbo.Stuff s 
   ON s.Id = wl.StuffId;

--WAITFOR DELAY '00:00:20';
COMMIT TRANSACTION;