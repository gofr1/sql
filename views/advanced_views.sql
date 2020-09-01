USE DEMO;

--persisted view 
-- view with index

DROP TABLE IF EXISTS dbo.Person;

CREATE TABLE dbo.Person (
    Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL
);

INSERT INTO dbo.Person (FirstName, LastName) VALUES
('John', 'Smith'), ('Vasiliy','Pupkin'),('Thomas','Anderson');

DROP TABLE IF EXISTS dbo.Stuff;

CREATE TABLE dbo.Stuff (
    Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    Name varchar(50) NOT NULL
);

INSERT INTO dbo.Stuff (Name) VALUES
('Phone'),('Cup'),('T-Shirt'),('Laptop'),('Knife'),('Bike');

DROP TABLE IF EXISTS dbo.Wishlist;

CREATE TABLE dbo.Wishlist (
    PersonId INT NOT NULL,
    StuffId INT NOT NULL,
    CONSTRAINT FK_Wishlist_PersonId FOREIGN KEY (PersonId) REFERENCES dbo.Person (Id),
    CONSTRAINT FK_Wishlist_StuffId FOREIGN KEY (StuffId) REFERENCES dbo.Stuff (Id)
);

INSERT INTO dbo.Wishlist (PersonId, StuffId) VALUES (1,6),(2,1),(2,4),(3,3);
GO

CREATE VIEW dbo.WishlistExplained
WITH SCHEMABINDING -- after that we can not make significant
-- changes to existed tables used in view
AS
SELECT  CONCAT(p.FirstName,' ',p.LastName) as PersonName,
        s.Name as StuffName
FROM dbo.Wishlist wh 
INNER JOIN dbo.Person p 
    ON wh.PersonId = p.Id
INNER JOIN dbo.[Stuff] s 
    ON wh.StuffId = s.Id
GO
-- now we can add some indexes to view
CREATE UNIQUE CLUSTERED INDEX IDX_WishlistExplained
   ON dbo.WishlistExplained (PersonName, StuffName);

SELECT * FROM dbo.WishlistExplained 

INSERT INTO dbo.Person (FirstName, LastName) VALUES
('Harry', 'Potter')

INSERT INTO dbo.Wishlist (PersonId, StuffId) VALUES (4,2),(4,5)