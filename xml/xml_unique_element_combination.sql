;WITH YourTable AS (
SELECT *
FROM (VALUES
('Red'),
('Blue'),
('Green'),
('Yellow'),
('Purple'),
('White')
) as t(colour)
), cte AS (
    SELECT  t.c.value('../@rn','int') as rn,
            t.c.value('.','nvarchar(max)') as colour
    FROM (
        SELECT  ROW_NUMBER() OVER (ORDER BY y.colour, y1.colour) as '@rn',
                CAST('<colour>'+y.colour + '</colour><colour>' + y1.colour +'</colour>' as xml) 
        FROM YourTable y
        CROSS JOIN YourTable y1
        WHERE y.colour != y1.colour
        FOR XML PATH('root'), ELEMENTS, TYPE 
    ) as A(X)
    CROSS APPLY A.X.nodes('/root/colour') as t(c)
)
 
SELECT DISTINCT STUFF((
            SELECT ' - ' + colour
            FROM cte
            WHERE c.rn = rn
            ORDER BY colour
            FOR XML PATH('')
        ),1,3,'') as c
FROM cte c