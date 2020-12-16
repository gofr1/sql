USE AdventureWorks2017;

--! Batch mode execution 
--? is a query processing method, and the advantage of this query 
--? processing method is to handle multiple rows at a time. This approach gains us 
--? performance enhancement when a query performs aggregation, sorts, and group-by 
--? operations on a large amount of data

-- Take a look at exec plan
SET STATISTICS PROFILE, XML, TIME ON;

SELECT ModifiedDate,
       CarrierTrackingNumber,
       SUM(OrderQty * UnitPrice) Cost
FROM Sales.SalesOrderDetail
GROUP BY ModifiedDate,CarrierTrackingNumber;

SET STATISTICS PROFILE, XML, TIME OFF;

--* SQL Server Execution Times:
--* CPU time = 250 ms, elapsed time = 94 ms. 
--* Batch execution time: 00:00:00.621 

--* <RelOp NodeId="4" PhysicalOp="Clustered Index Scan" LogicalOp="Clustered Index Scan" EstimateRows="121317" ... EstimatedExecutionMode="Row">
-- and Batches="0" everywhere

SELECT i.name
FROM sys.indexes i 
INNER JOIN sys.tables t 
    ON t.object_id = i.object_id
WHERE t.name = 'SalesOrderDetail' AND index_id = 1
--* PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID

ALTER TABLE Sales.SalesOrderDetail DROP CONSTRAINT IF EXISTS PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID;
GO
DROP TRIGGER IF EXISTS Sales.iduSalesOrderDetail
GO
-- You cannot create so let's drop trigger and create CCI
CREATE CLUSTERED COLUMNSTORE INDEX idx_ccs_SalesOrderDetail ON Sales.SalesOrderDetail;
GO
--! Msg 35359, Level 16, State 1, Line 1
--! The statement failed because a table with a clustered columnstore index cannot have triggers. 
--! Consider removing all triggers from the table and then creating the clustered columnstore index. 

-- Take a look at exec plan once again
SET STATISTICS PROFILE, XML, TIME ON;

SELECT ModifiedDate,
       CarrierTrackingNumber,
       SUM(OrderQty * UnitPrice) Cost
FROM Sales.SalesOrderDetail
GROUP BY ModifiedDate,CarrierTrackingNumber;

SET STATISTICS PROFILE, XML, TIME OFF;


--* SQL Server Execution Times:
--* CPU time = 20 ms, elapsed time = 53 ms. 
--* Batch execution time: 00:00:00.116 


--* <RelOp NodeId="2" PhysicalOp="Clustered Index Scan" LogicalOp="Clustered Index Scan" EstimateRows="121317" ... EstimatedExecutionMode="Batch">
--* <RunTimeCountersPerThread Thread="0" ActualRows="121317" Batches="365" ActualExecutionMode="Batch" ...

DROP INDEX IF EXISTS idx_ccs_SalesOrderDetail ON Sales.SalesOrderDetail;

-- run _rollback.sql script to get original PK and TRIGGER back