USE DEMO;

WITH cte AS (
    SELECT *
    FROM (VALUES 
    ('01/01', 'Sam', 'Manager'),
    ('02/01', 'Sam', 'Manager'),
    ('01/01', 'Dan', 'Manager'),
    ('01/01', 'Dom', 'Manager'),
    ('01/01', 'Bob', 'Analyst'),
    ('02/01', 'Bob', 'Analyst'),
    ('01/01', 'Mike', 'Analyst'),
    ('03/01', 'Mike', 'Analyst'),
    ('01/01', 'Fred', 'Specialist')
) as t(dt, name, job)
)

SELECT dt, 
       name, 
       job, 
       DENSE_RANK() over (PARTITION by job order by name asc) +
       DENSE_RANK() over (PARTITION by job order by name desc) - 1 cnt_distinct
FROM cte
GROUP BY dt, name, job
ORDER BY job, name, dt
