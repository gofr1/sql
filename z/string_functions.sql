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

