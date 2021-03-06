USE DEMO;

-- READPAST Query Hint
-- If we specify the READPAST hint in the SQL queries, the database engine 
-- ignores the rows locked by other transactions while reading data. 
DROP TABLE IF EXISTS dbo.Products;

CREATE TABLE dbo.Products (
    Id int IDENTITY(1,1),
    ProductName VARCHAR(20),
    CONSTRAINT PK_Products_Id PRIMARY KEY (Id)
);

INSERT INTO dbo.Products (ProductName) 
VALUES ('Laptop'),
('Mouse'),
('Keyboard'),
('LAN Cable'),
('Wireless Router');

-- Exexute tran.sql and try query below:

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM dbo.Products WITH (NOLOCK);
--* Id  ProductName
--* 1   Mac
--* 2   Mac
--* 3   Keyboard
--* 4   LAN Cable
--* 5   Wireless Router

SELECT *
FROM dbo.Products  WITH (READPAST);
--* Id  ProductName
--* 3   Keyboard
--* 4   LAN Cable
--* 5   Wireless Router

--! You can only specify the READPAST lock in the READ COMMITTED or REPEATABLE READ isolation levels. 
