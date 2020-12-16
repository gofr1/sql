DECLARE @x xml,
        @n int = 4
 
;WITH YourTable AS (
    SELECT  CAST(SomeString as nvarchar(max)) as SomeString
    FROM (VALUES ('ABCD'),('1234'),('A1B2'),('WXYZ')
) as t(SomeString)
), cte AS (
    SELECT  SomeString+'</u></row>' as d,
            1 as [seq],
            1 as [level],
            LEN(SomeString) as l,
            SomeString as OrigString
    FROM YourTable
    UNION ALL
    SELECT  STUFF(d,[seq]+1,0,'</u><u>'),
            [seq]+8,
            [level]+1,
            l,
            OrigString
    FROM cte
    WHERE l >= [level]+1
)
 
SELECT @x = (
    SELECT TOP 1 WITH TIES CAST('<row str="'+OrigString+'"><u>'+d as xml)
    FROM cte
    ORDER BY [level] desc
    FOR XML PATH('')
)
 
;WITH final AS (
SELECT  t.v.value('../@str','nvarchar(max)') as OrigString,
        CHAR(ASCII(t.v.value('.','nvarchar(1)'))+@n) as PartsOfNewString
FROM @x.nodes('/row/u') as t(v)
)
 
SELECT DISTINCT f.OrigString,
        (SELECT PartsOfNewString+''
        FROM final
        WHERE OrigString = f.OrigString
        FOR XML PATH('')) as NewString
FROM final f
OPTION (MAXRECURSION 0)