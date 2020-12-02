USE DEMO;

--! Batch mode execution 
--? is a query processing method, and the advantage of this query 
--? processing method is to handle multiple rows at a time. This approach gains us 
--? performance enhancement when a query performs aggregation, sorts, and group-by 
--? operations on a large amount of data

-- Checking if batch mode is activated
SELECT [name],
       IIF([value] = 1, 'ON', 'OFF') 
FROM sys.database_scoped_configurations
WHERE [name] = 'BATCH_MODE_ON_ROWSTORE';

-- One way to control them is to use hints ALLOW_BATCH_MODE and DISALLOW_BATCH_MODE. Using the hint on the above query.
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF; --Disable
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = ON; --Enable

DROP TABLE IF EXISTS dbo.BatchTest;
GO

CREATE TABLE dbo.BatchTest (
    Id INT NOT NULL IDENTITY(1,1),
    OrderId UNIQUEIDENTIFIER NOT NULL,
    Product NVARCHAR(200) NOT NULL,
    Qty DECIMAL(10,8) NOT NULL,
    Price DECIMAL(10,8) NOT NULL,
    CONSTRAINT PK_BatchTest_Id PRIMARY KEY (Id ASC)
);
GO

SET STATISTICS PROFILE, XML, TIME ON;

SELECT COUNT(*)
FROM dbo.BatchTest

SET STATISTICS PROFILE, XML, TIME OFF;

--! <StmtSimple StatementText="SELECT COUNT(*)&#xa;FROM dbo.BatchTest" StatementId="2" StatementCompId="2" ... BatchModeOnRowStoreUsed="true">
--* <RelOp NodeId="3" PhysicalOp="Clustered Index Scan" LogicalOp="Clustered Index Scan" EstimateRows="595079" EstimatedRowsRead="595079" EstimateIO="5.21053" EstimateCPU="0.327372" AvgRowSize="9" EstimatedTotalSubtreeCost="5.5379" TableCardinality="595079" Parallel="1" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch">
--*   <OutputList></OutputList>
--*   <RunTimeInformation>
--!     <RunTimeCountersPerThread Thread="4" ActualRows="114703" Batches="128" ActualExecutionMode="Batch" ActualElapsedms="11" ActualCPUms="11" ActualScans="1" ActualLogicalReads="1361" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="114703" ActualEndOfScans="0" ActualExecutions="1"></RunTimeCountersPerThread>
--!     <RunTimeCountersPerThread Thread="3" ActualRows="91731" Batches="102" ActualExecutionMode="Batch" ActualElapsedms="14" ActualCPUms="10" ActualScans="1" ActualLogicalReads="1088" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="91731" ActualEndOfScans="0" ActualExecutions="1"></RunTimeCountersPerThread>
--!     <RunTimeCountersPerThread Thread="2" ActualRows="178181" Batches="198" ActualExecutionMode="Batch" ActualElapsedms="17" ActualCPUms="17" ActualScans="1" ActualLogicalReads="2112" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="178181" ActualEndOfScans="0" ActualExecutions="1"></RunTimeCountersPerThread>
--!     <RunTimeCountersPerThread Thread="1" ActualRows="210464" Batches="234" ActualExecutionMode="Batch" ActualElapsedms="24" ActualCPUms="24" ActualScans="1" ActualLogicalReads="2496" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="210464" ActualEndOfScans="0" ActualExecutions="1"></RunTimeCountersPerThread>
--!     <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualEndOfScans="0" ActualExecutions="0"></RunTimeCountersPerThread>
--*   </RunTimeInformation>
--*   <IndexScan Ordered="0" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore">
--*     <DefinedValues></DefinedValues>
--*     <Object Database="[DEMO]" Schema="[dbo]" Table="[BatchTest]" Index="[PK_BatchTest_Id]" IndexKind="Clustered" Storage="RowStore"></Object>
--*   </IndexScan>
--* </RelOp>
-- Here we can see that BatchModeOnRowStoreUsed was used 

--* SQL Server Execution Times:
--* CPU time = 78 ms, elapsed time = 38 ms. 

-- Now same query with forced disable of batch mode
SET STATISTICS PROFILE, XML, TIME ON;

SELECT COUNT(*)
FROM dbo.BatchTest
OPTION (RECOMPILE, USE HINT('DISALLOW_BATCH_MODE'))

SET STATISTICS PROFILE, XML, TIME OFF;

--* SQL Server Execution Times:
--* CPU time = 224 ms, elapsed time = 81 ms. 