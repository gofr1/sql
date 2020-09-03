USE DEMO;

--UNION ALL - Includes duplicates.
--UNION - Excludes duplicates.

SELECT * 
FROM dbo.TableOne
UNION ALL
SELECT * 
FROM dbo.TableTwo; -- 7 rows

SELECT * 
FROM dbo.TableOne
UNION
SELECT * 
FROM dbo.TableTwo; -- 5 row