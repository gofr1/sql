/*
Unicode support in SQL Server

* nchar and nvarchar both use UTF-16 encoding
* UTF-16 uses two bytes of data to store each character

* SQL 2019 allows char and varchar to use UTF-8
* UTF-8 use one to four bytes of storage per character

*/

USE DEMO;

-- get list of collations with UTF8 support (select only Latin)
SELECT * FROM fn_helpcollations() WHERE name like '%Latin%UTF8';

-- create a table to test UTF-8 collation
DROP TABLE IF EXISTS dbo.UnicodeTest;
CREATE TABLE dbo.UnicodeTest (
    myChar8 CHAR(8),
    myVarChar8 VARCHAR(8),
    myNChar8 NCHAR(8),
    myNVarChar8 NVARCHAR(8),
    myUTF8 NVARCHAR(8) COLLATE Latin1_General_100_CI_AS_SC_UTF8
);

-- see what collation each column is using
SELECT c.name, 
       c.collation_name
FROM sys.columns c
INNER JOIN sys.tables t 
    ON t.object_id = c.object_id
WHERE t.name = 'UnicodeTest'

-- insert some unicode data in a table
INSERT INTO dbo.UnicodeTest VALUES
(N'A', N'A', N'A', N'A', N'A'),
(N'⪅', N'⪅', N'⪅', N'⪅', N'⪅'), -- lessapprox
(N'☃️', N'☃️', N'☃️', N'☃️', N'☃️'); -- snowman

-- select
-- data
SELECT myChar8,
       myVarChar8,
       myNChar8,
       myNVarChar8,
       myUTF8
FROM dbo.UnicodeTest;

-- length of string 
SELECT LEN(myChar8) lenC8,
       LEN(myVarChar8) lenVC8,
       LEN(myNChar8) lenN8,
       LEN(myNVarChar8) lenNC8,
       LEN(myUTF8) lenU8
FROM dbo.UnicodeTest;

-- data length
SELECT DATALENGTH(myChar8) dlC8,
       DATALENGTH(myVarChar8) dlVC8,
       DATALENGTH(myNChar8) dlN8,
       DATALENGTH(myNVarChar8) dlNC8,
       DATALENGTH(myUTF8) dlU8
FROM dbo.UnicodeTest;