USE AdventureWorksDW2012;
--Not a big table, so not much performance improvement

--* A columnstore is data that's logically organized as a table with rows and columns, 
--* and physically stored in a column-wise data format.

SET STATISTICS PROFILE, XML, IO, TIME ON;

--CPU time = 76 ms, elapsed time = 85 ms. 
--logical reads 1313
SELECT YEAR(OrderDate),
       MONTH(OrderDate),
       SUM(SalesAmount)
FROM dbo.FactInternetSales --WITH (INDEX(idx_cs_FactInternetSales))
GROUP BY YEAR(OrderDate),
         MONTH(OrderDate)
ORDER BY YEAR(OrderDate),
         MONTH(OrderDate);

SET STATISTICS PROFILE, XML, IO, TIME  OFF;

DROP INDEX IF EXISTS idx_cs_FactInternetSales ON dbo.FactInternetSales;
--* The nonclustered index contains a copy of part or all of the rows and columns in the 
--* underlying table. The index is defined as one or more columns of the table and has an optional condition that filters the rows.
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_cs_FactInternetSales 
ON dbo.FactInternetSales (OrderDate, SalesAmount); 
--CPU time = 38 ms, elapsed time = 51 ms. 
--lob read-ahead reads 112

-- To use Clustered cci you need to drop existing one
ALTER TABLE [dbo].[FactInternetSales] DROP CONSTRAINT [PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber];

DROP INDEX IF EXISTS idx_ccs_FactInternetSales ON dbo.FactInternetSales;
--* A clustered columnstore index is the primary storage for the entire table
CREATE CLUSTERED COLUMNSTORE INDEX idx_ccs_FactInternetSales ON dbo.FactInternetSales;
--CPU time = 24 ms, elapsed time = 24 ms.
--lob read-ahead reads 69 

--Rollback
ALTER TABLE [dbo].[FactInternetSales] ADD CONSTRAINT [PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber] PRIMARY KEY CLUSTERED 
(
	[SalesOrderNumber] ASC,
	[SalesOrderLineNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

