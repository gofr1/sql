USE DEMO;

DECLARE @xml xml;

WITH cte AS (
SELECT *
FROM (VALUES
(1, 'Today is a good day!'),
(2, 'Whatever'),
(3, 'Hello my friend')
) as t(ID, String)
)

SELECT @xml = (
SELECT CAST('<i id="' + CAST(ID as nvarchar(10)) + '"><w>' + REPLACE(REPLACE(String,' ','</w><w>'),'&','&amp;') + '</w></i>' as xml)
FROM cte
FOR XML PATH('')
);

SELECT  t.v.value('@id','int') as ID,
        t.v.value('w[1]','nvarchar(10)') as String1,
        t.v.value('w[2]','nvarchar(10)') as String2,
        t.v.value('w[3]','nvarchar(10)') as String3,
        t.v.value('w[4]','nvarchar(10)') as String4,
        t.v.value('w[5]','nvarchar(10)') as String5,
        t.v.value('w[6]','nvarchar(10)') as String6
FROM @xml.nodes('/i') as t(v);