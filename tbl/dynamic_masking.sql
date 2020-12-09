USE DEMO;

DROP TABLE IF EXISTS dbo.Emails;

CREATE TABLE dbo.Emails (
    Id int IDENTITY(1,1) NOT NULL,
    Email varchar(50)  MASKED WITH (FUNCTION = 'email()') NOT NULL,
    CONSTRAINT PK_EmailsId PRIMARY KEY CLUSTERED (Id)
);

INSERT INTO dbo.Emails (Email) VALUES
('example@domain.com');

SELECT * FROM dbo.Emails;

-- Testing on guest user
GRANT CONNECT TO guest;
GRANT SELECT TO guest;

--Now after giving rights execute
EXECUTE AS USER = 'guest';
SELECT * FROM dbo.Emails;
REVERT;

--* Id  Email
--* 1   eXXX@XXXX.com
--* 2   sXXX@XXXX.com
--* 3   eXXX@XXXX.com
--* 4   mXXX@XXXX.com

-- Now grant guest unmask rights
GRANT UNMASK TO guest;

--Now with rights to unmask execute
EXECUTE AS USER = 'guest';
SELECT * FROM dbo.Emails;
REVERT;

--* Id  Email
--* 1   example@domain.com
--* 2   some@email.com
--* 3   email@example.com
--* 4   myemail@domain.com

-- Great!

-- Take the rights away
REVOKE UNMASK TO guest;
REVOKE SELECT TO guest;
REVOKE CONNECT TO guest;

-- Remove masking
ALTER TABLE dbo.Emails ALTER COLUMN Email DROP MASKED;  

-- Querying for Masked Columns
SELECT c.name, 
       tbl.name as table_name, 
       c.is_masked, 
       c.masking_function  
FROM sys.masked_columns AS c  
JOIN sys.tables AS tbl   
    ON c.[object_id] = tbl.[object_id]  
WHERE is_masked = 1;  

--* name     table_name  is_masked  masking_function
--* Email    Emails      1          email()