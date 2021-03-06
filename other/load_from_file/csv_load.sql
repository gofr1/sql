USE DEMO;

SELECT *
FROM OPENROWSET (
    BULK '/var/opt/mssql/load/test_CSV_File.txt', 
    SINGLE_CLOB) AS DATA;

--Insert from file with no header
DROP TABLE IF EXISTS dbo.TestCSVLoad;
 
CREATE TABLE dbo.TestCSVLoad (
    PersonID INT,
    FullName VARCHAR(512),
    PreferredName VARCHAR(512),
    SearchName VARCHAR(512),
    IsPermittedToLogon BIT,
    LogonName VARCHAR(512)
);

BULK INSERT dbo.TestCSVLoad
FROM '/var/opt/mssql/load/test_CSV_File.txt'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n' --for windows it is usually \r\n
); 

SELECT *
FROM dbo.TestCSVLoad;

--Read from csv with file format
SELECT *
FROM OPENROWSET (
    BULK '/var/opt/mssql/load/small.csv', 
    FORMATFILE = '/var/opt/mssql/load/small.fmt'
) AS DATA;

