USE DEMO;

DROP TABLE IF EXISTS dbo.Tools;

-- Create a table.  
CREATE TABLE dbo.Tools (
    ID INT IDENTITY NOT NULL PRIMARY KEY,
    [Name] VARCHAR(40) NOT NULL
);

-- Inserting values into Tools table.  
INSERT INTO dbo.Tools ([Name])
VALUES ('Screwdriver'), ('Hammer'), ('Saw'), ('Shovel');
  
-- Create a gap in the identity values.  
DELETE dbo.Tools WHERE Name = 'Saw';

SELECT *
FROM dbo.Tools;
  
-- Try to insert an explicit ID value of 3;  
--! Cannot insert explicit value for identity column in table 'Tools' when IDENTITY_INSERT is set to OFF. 
INSERT INTO dbo.Tools (ID, [Name]) VALUES (3, 'Garden shovel');

-- SET IDENTITY_INSERT to ON.  
SET IDENTITY_INSERT dbo.Tools ON;

-- Try to insert an explicit ID value of 3.  
INSERT INTO dbo.Tools (ID, [Name]) VALUES (3, 'Garden shovel');

SELECT *   
FROM dbo.Tools;

-- If you try to insert into table when IDENTITY_INSERT IS ON w/o specifying id's
--! Explicit value must be specified for identity column in table 'Tools' either when IDENTITY_INSERT is set to ON 
--! or when a replication user is inserting into a NOT FOR REPLICATION identity column. 
INSERT INTO dbo.Tools ([Name])
VALUES ('Wrench'), ('Teardrop ratchet');

SET IDENTITY_INSERT dbo.Tools OFF;