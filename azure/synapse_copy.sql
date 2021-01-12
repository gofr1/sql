SELECT DB_NAME();

DROP TABLE dbo.market_data;

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

COPY INTO dbo.market_data ([Date], EPAM, XOM, VIX, AAPL, FB, AMJ, GOOG, ICHGF)
FROM 'https://mainstorageaccountv2.blob.core.windows.net/my-csv/market_data.csv'
WITH (
    FILE_TYPE = 'CSV',
    FIRSTROW = 2,
    CREDENTIAL = (
        IDENTITY = 'SHARED ACCESS SIGNATURE', 
        SECRET = '..'
    )
);

SELECT *
FROM dbo.market_data;
--* (941 rows affected) 