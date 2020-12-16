USE WideWorldImporters;

/*
Let's consider that sql server select a parallel execution at some point
here we have 3 threads, when first two threads will end there will be in 
CXPACKET state until the 3 thread is over 

                 Parallel region
               /|thread 1 50 rows  |\
|some operator|-|thread 2 75 rows  |-|another operator|
               \|thread 3 100 rows |/

also we have Coordinator thread that looks over  Parallel region and is waiting 
until all threads are finished (it is also in CXPACKET wait)
*/

SET STATISTICS PROFILE ON;

SELECT [CustomerID], COUNT([OrderID]) totOID
FROM [Sales].[Invoices] o
GROUP BY [CustomerID];

SET STATISTICS PROFILE OFF;

-- At some point you will see
--Parallelism Gather Streams
--Parallelism Repartition Streams

--*        |--Parallelism(Gather Streams)
--*            ..........
--*                       |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([o].[CustomerID]))

-- We create a stored procedure to execute the query above in a loop
DROP PROCEDURE IF EXISTS Sales.InvoicesCount 
GO

CREATE PROCEDURE Sales.InvoicesCount 
    @i int = 1000
AS
BEGIN
    WHILE @i > 0
    BEGIN
        SELECT [CustomerID], COUNT([OrderID]) totOID
        FROM [Sales].[Invoices] o
        GROUP BY [CustomerID]

        SET @i -= 1
    END
END

--Clear the waits stat
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

--No launch this procedure in different session
/*
SELECT @@SPID --Take this session_id and use it in below queries 

EXECUTE [Sales].[InvoicesCount] 
GO
*/
--And lets check what we have
SELECT *
FROM sys.dm_os_wait_stats
WHERE wait_type = 'CXPACKET';

SELECT session_id,
       wait_type, 
       start_time,
       [status],
       command,
       s.*
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
where session_id = 74;

SELECT *
FROM sys.dm_os_waiting_tasks
WHERE session_id = 74
AND exec_context_id = 0; --this are coordinators
