DECLARE @date_start date = '2016-01-01',
        @date_end date = '2016-12-31';

WITH cte as (
SELECT @date_start as [d], 0 as Level
UNION ALL
SELECT DATEADD(day,1,[d]), [level] + 1 as [level]
from cte
WHERE [level] < DATEDIFF(day,@date_start,@date_end)
), holidays as ( --table with holidays
SELECT * FROM (VALUES
('2016-01-01'),
('2016-01-18'),
('2016-02-15'),
('2016-05-30'),
('2016-07-04'),
('2016-09-05'),
('2016-10-10'),
('2016-11-11'),
('2016-11-24'),
('2016-12-26')) as t(d)
)

SELECT c.d CalendarDate,
       CASE WHEN DATEPART(WEEKDAY,c.d) IN (1,7) or h.d IS NOT NULL THEN 1 ELSE 0 END as isHoliday
FROM cte c
LEFT JOIN holidays h 
    ON c.d = h.d
OPTION (MAXRECURSION 1000); --if you need more than 3 years get MAXRECURSION up