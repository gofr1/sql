USE DEMO;

--! STRING_SPLIT
-- A table-valued function that splits a string into rows of substrings, based on a specified separator characte
-- SQL Server 2016 and later

SELECT spl.[value]
FROM (VALUES ('Some, text, to, split')) as t(txt)
CROSS APPLY STRING_SPLIT(txt, ',') spl;

--* value
--* Some
--*  text
--*  to
--*  split

WITH Order_ AS (
    SELECT OrderId,
           DeviceInfo                
    FROM (VALUES 
    (10, 'PageSize|BGColor|3000|V1.0'),
    (11, 'PageSize|BGColor|3000|V2.0'),
    (12, 'PageSize|BGColor|3000|V3.0')
    ) as t(OrderId, DeviceInfo)
)

SELECT ord.OrderId, 
       ord.DeviceInfo, 
       di.[Value], 
       ROW_NUMBER() OVER(PARTITION BY ord.DeviceInfo ORDER BY ord.OrderId ASC) rn
FROM Order_ ord
CROSS APPLY STRING_SPLIT(DeviceInfo, '|') di 
WHERE ord.DeviceInfo IS NOT NULL OR ord.DeviceInfo != ''

--! STRING_ESCAPE
-- Escapes special characters in texts and returns text with escaped characters. 
-- STRING_ESCAPE is a deterministic function, introduced in SQL Server 2016.

-- Currently the value supported is 'json'.

SELECT STRING_ESCAPE('\	/
\\	"	', 'json') AS escapedText;  

--* escapedText
--* \\\t\/\n\\\\\t\"\t

SELECT FORMATMESSAGE('{ "id": %d,"name": "%s", "surname": "%s" }',17, STRING_ESCAPE('John','json'), STRING_ESCAPE('
Wick','json') ) as msg; 

--* {
--*     "id": 17,
--*     "name": "John",
--*     "surname": "\nWick"
--* }

-- The following example produces a list of names in a single result cell, separated with carriage returns.
-- Great for creating CSV files
SELECT TOP 1
       OrderId,
       --! STRING_AGG aggregation result exceeded the limit of 8000 bytes. Use LOB types to avoid result truncation.
       -- Need conversion into NVARCHAR(MAX)
       STRING_AGG(CONVERT(NVARCHAR(MAX),CONCAT(Product, ';', Qty, ';', Price)), CHAR(10)) AS csv 
FROM dbo.BatchTest
GROUP BY OrderId;

--* OrderId                                  csv
--* fe281cbd-a7f9-4689-8d18-00031cca6a1e     coral socks XXL;3.00000000;3.26383631
--*                                          salmon jeans S;5.00000000;18.68387378
--*                                          olive top XXL;8.00000000;7.93639459
--*                                          blue underpants M;8.00000000;3.61008375
--*                                          blue tunic S;6.00000000;8.09766195
--*                                          pearl shirt M;8.00000000;8.05032989
--*                                          orange top M;7.00000000;7.47201544

-- or if you want a full dataset 
SELECT STRING_AGG(CONVERT(NVARCHAR(MAX),CONCAT(OrderId, ';', Product, ';', Qty, ';', Price)), CHAR(10)) AS csv 
FROM dbo.BatchTest
