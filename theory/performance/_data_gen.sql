-- Data generator for SARGABLE script
USE DEMO;

DROP TABLE IF EXISTS dbo.SearchARGumentABLE;

CREATE TABLE dbo.SearchARGumentABLE (
    OrderId UNIQUEIDENTIFIER NOT NULL,
    OrderDate DATE NOT NULL,
    CONSTRAINT PK_SearchARGumentABLE_OrderId PRIMARY KEY (OrderId ASC)
);

WITH dates AS (
    SELECT 1 as id, 
           CAST('2000-01-01' as date) dt
    UNION ALL 
    SELECT id + 1,
           DATEADD(dd,  (CAST (NEWID() AS BINARY (6)) % 10), dt)
    FROM dates
    WHERE id < 108000
), orders AS (
    SELECT DISTINCT OrderId
    FROM dbo.BatchTest
), orders_ AS (
    SELECT ROW_NUMBER() OVER (ORDER BY OrderId) as id,
        OrderId
    FROM orders
)

INSERT INTO dbo.SearchARGumentABLE (OrderId, OrderDate)
SELECT OrderId, dt
FROM orders_ o 
INNER JOIN dates d 
    ON o.id = d.id
OPTION(MAXRECURSION 0);

CREATE INDEX IX_NCI_SearchARGumentABLE_OrderDate ON dbo.SearchARGumentABLE (OrderDate ASC);