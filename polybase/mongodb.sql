USE PolybaseTesting;

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'VeryStr0ngPa$$wordG0esHere';

--Specify credentials to external data source
--IDENTITY: user name for external source. 
--SECRET: password for external source.
DROP DATABASE SCOPED CREDENTIAL mongo_credentials;

CREATE DATABASE SCOPED CREDENTIAL mongo_credentials 
WITH IDENTITY = N'testsql', Secret = N'testsql';

--LOCATION: Location string should be of format '<type>://<server>[:<port>]'.
--PUSHDOWN: specify whether computation should be pushed down to the source. ON by default.
--CONNECTION_OPTIONS: Specify driver location
--CREDENTIAL: the database scoped credential, created above.

DROP EXTERNAL DATA SOURCE my_mongodb;

CREATE EXTERNAL DATA SOURCE my_mongodb
WITH (
    LOCATION = 'mongodb://localhost:27017',
    -- PUSHDOWN = ON | OFF,
    CONNECTION_OPTIONS = 'ssl=false;',
    CREDENTIAL = mongo_credentials
);

--*{
--*  "_id": "01001",
--*  "city": "AGAWAM",
--*  "loc": [
--*    -72.622739,
--*    42.070206
--*  ],
--*  "pop": 15338,
--*  "state": "MA"
--*}

DROP EXTERNAL TABLE zips;

CREATE EXTERNAL TABLE zips(
    [_id] NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [city] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS,
    --[zips_loc] FLOAT(53),
    [pop] INT,
    [state] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS
)
WITH (
    LOCATION='test.zips',
    DATA_SOURCE= my_mongodb
);

--Check table data
SELECT [_id], [city], [pop], [state]
FROM dbo.zips
WHERE _id = N'01001';

--*{
--*  "_id": 10,
--*  "item": "Mpuse",
--*  "qty": 50,
--*  "type": "Computer"
--*}

DROP EXTERNAL TABLE dbo.products;

CREATE EXTERNAL TABLE products (
    [_id]  NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [item] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS,
    [qty] FLOAT(53),
    [type] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS
)
WITH (
    LOCATION='test.products',
    DATA_SOURCE= my_mongodb
);

SELECT *
FROM dbo.products;
