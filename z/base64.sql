;WITH cte AS (
    SELECT *
    FROM (VALUES
    (1, 'test1'),
    (2, 'test2')
) AS t(Id, [Desc])
)

SELECT  Id,
        [Desc],
        CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'NVARCHAR(MAX)') as Base64String
FROM (
    SELECT Id, [Desc], CAST(CAST(Id as varchar(10)) + [Desc] AS VARBINARY(MAX)) AS bin
    FROM cte
) as t