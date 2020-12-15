USE DEMO;

--Enable Full-text search on the DB
IF (SELECT DATABASEPROPERTY(DB_NAME(), N'IsFullTextEnabled')) <> 1
EXEC sp_fulltext_database N'enable'
GO

--Create a full-text catalog
IF NOT EXISTS (SELECT * FROM dbo.sysfulltextcatalogs WHERE [name] = N'CatalogName')
EXEC sp_fulltext_catalog N'CatalogName', N'create'
GO

EXEC sp_fulltext_table N'dbo.SearchView', N'create', N'CatalogName', N'IndexName'
GO

--Add a column to catalog
EXEC sp_fulltext_column N'dbo.SearchView', N'search_string', N'add', 0 /* neutral */
GO

--Activate full-text for table/view
EXEC sp_fulltext_table N'dbo.SearchView', N'activate'
GO

--Full-text index update
exec sp_fulltext_catalog 'CatalogName', 'start_full'
GO