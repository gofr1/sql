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
