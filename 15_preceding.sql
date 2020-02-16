create table payment (
  custid int,
  trdate date,
  amount decimal(10,2)
)

insert into payment (custid, trdate, amount) values
(1, '2019-11-10', 100.78),
(1, '2019-11-11', 16.80),
(1, '2019-11-12', 12.10),
(1, '2019-11-13', 7.90),
(1, '2019-11-15', 158.00),
(1, '2019-11-20', 29.12),
(1, '2019-11-25', 345.00),
(1, '2019-11-29', 70.50)

select custid,
       trdate,
       amount,
       sum(amount) over (partition by custid order by trdate) as running_total,
       sum(amount) over (partition by custid order by trdate
       rows between unbounded preceding and 1 preceding) 
       as spending,
       avg(amount) over (partition by custid order by trdate rows between 3 preceding and current row)
from payment