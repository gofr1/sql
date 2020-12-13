USE DEMO;

--! Pivot
-- Simple example of pivoting 
-- from rows to columns
WITH pivot_ AS (
    SELECT 1 as id,
           'first' as [name],
           10000 as salary
    UNION ALL
    SELECT 2, 'second', 12000
    UNION ALL 
    SELECT 3, 'third', 8000
)

SELECT *
FROM (
    SELECT [name],
           salary
    FROM pivot_
 ) p
PIVOT (MAX(salary)
FOR [name] IN ([first], [second], [third])
) pvt;

--* first   second  third
--* 10000   12000   8000

--! UNPIVOT

WITH unpivot_ AS (
    SELECT 10000 as [first],
           12000 as [second],
           8000 as [third]
)
SELECT [name],
       [salary]
FROM unpivot_ u
UNPIVOT (salary FOR [name] IN ([first], [second], [third])  
) unpvt;  

--* name     salary
--* first    10000
--* second   12000
--* third    8000