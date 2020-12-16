DECLARE @t TABLE (number int)
INSERT INTO @t VALUES
(104723),(104729),(9998),(448),(7),(241)
 
DECLARE @maxNum int
SELECT @maxNum = MAX(number) 
FROM @t
 
;WITH cte AS (
    SELECT 2 AS num 
    UNION ALL
    SELECT num+1 
    FROM cte 
    WHERE num < @maxNum
)
 
SELECT number
FROM @t t
CROSS JOIN Cte c
WHERE t.number%c.num=0 
GROUP BY number
HAVING COUNT(num) = 1
OPTION (MAXRECURSION 0)