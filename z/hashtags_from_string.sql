USE DEMO;

DECLARE @text nvarchar(max) = N'I #want to extract all #hastags out of this string, #vscode #SQL'

SELECT t.c.value('.','nvarchar(max)')
FROM (
    --In this part we convert input text into XML
    SELECT CAST('<a>'+REPLACE((SELECT @text FOR XML PATH('')),' ','</a><a>')+'</a>' as xml) as xm
) as x
CROSS APPLY x.xm.nodes('/a') as t(c) 
WHERE t.c.exist('. [contains(., "#")]') = 1; --check if each part contains #
