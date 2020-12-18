USE DEMO;

SELECT COUNT(DISTINCT Product)
FROM dbo.BatchTest

-- Test Table
DROP TABLE IF EXISTS dbo.FTStest;
GO

CREATE TABLE dbo.FTStest (
    Id INT NOT NULL IDENTITY(1,1),
    OrderId UNIQUEIDENTIFIER NOT NULL,
    Product NVARCHAR(200) NOT NULL,
    Qty INT NOT NULL,
    Price DECIMAL(10,8) NOT NULL,
    CONSTRAINT PK_FTStest_Id PRIMARY KEY (Id ASC)
);
GO

INSERT INTO dbo.FTStest (OrderId, Product, Qty, Price)
SELECT OrderId,
       Product,
       CAST(Qty as int),
       Price
FROM dbo.BatchTest;
GO

--Enable Full-text search on the DB
IF (SELECT DATABASEPROPERTY(DB_NAME(), N'IsFullTextEnabled')) <> 1
EXEC sp_fulltext_database N'enable'
GO

--Create a full-text catalog
IF NOT EXISTS (SELECT * FROM dbo.sysfulltextcatalogs WHERE [name] = N'CatalogFTStest')
EXEC sp_fulltext_catalog N'CatalogFTStest', N'create'
GO

EXEC sp_fulltext_table N'dbo.FTStest', N'create', N'CatalogFTStest', N'PK_FTStest_Id'
GO

--Add a column to catalog
EXEC sp_fulltext_column N'dbo.FTStest', N'Product', N'add', 0 /* neutral */
GO

-- Activate full-text for table/view
EXEC sp_fulltext_table N'dbo.FTStest', N'activate'
GO

-- Full-text index update
EXEC sp_fulltext_catalog 'CatalogFTStest', 'start_full'
GO

SELECT * 
FROM dbo.sysfulltextcatalogs 
WHERE [name] = N'CatalogFTStest'

SET STATISTICS IO, TIME, PROFILE ON;

--* (2894 rows affected)

SELECT f.*
FROM dbo.FTStest f
INNER JOIN CONTAINSTABLE (dbo.FTStest, Product, '"XXL" AND "Green"') as c 
    ON c.[KEY] = f.id
--* CPU time = 187 ms, elapsed time = 186 ms. 

SELECT f.*
FROM dbo.FTStest f
WHERE CONTAINS(Product, '"XXL" AND "Green"') 
--* CPU time = 223 ms, elapsed time = 223 ms. 

SELECT *
FROM dbo.FTStest
WHERE Product like '%green%XXL%'  
--* CPU time = 2100 ms, elapsed time = 756 ms. 

SELECT *
FROM dbo.FTStest
WHERE Product like '%green%' AND Product LIKE '%XXL%'  
--* CPU time = 2128 ms, elapsed time = 819 ms. 

SET STATISTICS IO, TIME, PROFILE OFF;

-- Adding NCI index will not help in that kind of searches
CREATE NONCLUSTERED INDEX NCI_FTStest_Product ON dbo.FTStest (Product);

-- 0 = Newly created and not yet used
-- 1 = Being used for insert during fulltext index population or merge
-- 4 = Closed. Ready for query
-- 6 = Being used for merge input and ready for query
-- 8 = Marked for deletion. Will not be used for query and merge source.
-- A status of 4 or 6 means that the fragment is part of the logical full-text index and can be queried; that is, it is a queryable fragment.
SELECT *
FROM sys.fulltext_index_fragments
WHERE [status] IN (4, 6);  

ALTER FULLTEXT CATALOG CatalogFTStest REORGANIZE;  
GO  

SELECT *
FROM sys.fulltext_indexes;

SELECT *
FROM sys.fulltext_index_columns;