USE PolybaseTesting;

-- This script contains a way to bulk load data into on-premises SQL Server

--CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'VeryStr0ngPa$$wordG0esHere';

DROP DATABASE SCOPED CREDENTIAL DataCredentialsTest

CREATE DATABASE SCOPED CREDENTIAL DataCredentialsTest
WITH IDENTITY = 'SHARED ACCESS SIGNATURE', 
     SECRET = '..';

DROP EXTERNAL DATA SOURCE AzureStorageTest;

CREATE EXTERNAL DATA SOURCE AzureStorageTest WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://mainstorageaccountv2.blob.core.windows.net/my-csv',
    CREDENTIAL = DataCredentialsTest
);

-- DROP EXTERNAL FILE FORMAT CSVFileFormat;

-- CREATE EXTERNAL FILE FORMAT CSVFileFormat 
-- WITH (
--     FORMAT_TYPE = DelimitedText,
--     FORMAT_OPTIONS (
--         FIELD_TERMINATOR = ',',
--         DATE_FORMAT = 'yy-MMM-dd'
--     )
-- );

SELECT * 
FROM OPENROWSET (
   BULK 'market_data.csv',
   DATA_SOURCE = 'AzureStorageTest',
--    FORMAT = 'CSV',
--    FIRSTROW = 2
   SINGLE_CLOB
)  AS DataFile;


--Date,EPAM,XOM,VIX,AAPL,FB,AMJ,GOOG,ICHGF
--16-Feb-16,60.44,81.22,24.11,96.639999,101.610001,23.44,717.640015,33

DROP TABLE IF EXISTS dbo.market_data;

CREATE TABLE dbo.market_data (
    [Date] date,
    EPAM decimal(24,8),
    XOM decimal(24,8),
    VIX decimal(24,8),
    AAPL decimal(24,8),
    FB decimal(24,8),
    AMJ decimal(24,8),
    GOOG decimal(24,8),
    ICHGF decimal(24,8)
);

BULK INSERT dbo.market_data 
FROM 'market_data.csv'
WITH (DATA_SOURCE = 'AzureStorageTest',
      FORMAT = 'CSV',
      FIRSTROW = 2);
--* (941 rows affected) 

SELECT * 
FROM dbo.market_data;