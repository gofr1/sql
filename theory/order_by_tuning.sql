USE DEMO;


--! No index sort
SET STATISTICS PROFILE, XML, TIME ON;

SELECT OrderId
FROM dbo.BatchTest b 
ORDER BY b.OrderId

SET STATISTICS PROFILE, XML, TIME OFF;

-- 1st run
-- ActualRows="595079" EstimateRows="595079"
-- GrantedMemory="53824" IsMemoryGrantFeedbackAdjusted="No: First Execution"

-- 2nd run
-- GrantedMemory="84672" IsMemoryGrantFeedbackAdjusted="Yes: Adjusting"

-- 3rd run
-- GrantedMemory="53824" IsMemoryGrantFeedbackAdjusted="No: Accurate Grant"
-- SortSpillDetails GrantedMemoryKb="13360" UsedMemoryKb="13360" WritesToTempDb="429" ReadsFromTempDb="429"

-- At the same time, the following options can consider overcoming the tempdb spill issue:
--    Creating an index that tunes the ORDER BY statement performance
--    Using the MIN_GRANT_PERCENT query option
--    Update the outdated statistics


--! Sort by index
SET STATISTICS PROFILE, XML, TIME ON;

SELECT Id, OrderId
FROM dbo.BatchTest b 
ORDER BY b.Id

SET STATISTICS PROFILE, XML, TIME OFF;

-- IndexScan Ordered="1" ScanDirection="FORWARD"

--! Grant hints
-- The percentage value is based on the memory grant that's specified in the resource governor configuration. For example, consider the following scenario:
-- 
--     You have a resource pool whose maximum amount of memory is 10 gigabytes (GB).
--     You have a workload group in the resource pool, and the maximum memory grant of the query in the workload group is set to 10 GB * 50% = 5 GB.
--     You execute a query by using the following statement:

SET STATISTICS PROFILE, XML, TIME ON;

SELECT OrderId
FROM dbo.BatchTest b 
ORDER BY b.OrderId
OPTION (min_grant_percent = 10, max_grant_percent = 50)

SET STATISTICS PROFILE, XML, TIME OFF;

-- In this scenario, the minimum amount of memory that should be granted to the query is 5 GB * 10% = 0.5 GB, 
--nand the maximum amount of memory that it can't exceed is 5 GB * 50% = 2.5 GB. 
-- If this query obtains 1 GB without these options, it will obtain the same amount because 1 GB belongs to this minimum and maximum range.
-- The min_grant_percent memory grant option overrides the sp_configure option (minimum memory per query (KB)) regardless of the size.

-- Note These two new query memory grant options aren't available for index creation or rebuild.

-- On the server that has X GB memory, the maximum usable memory for the server (Y GB) is less than X GB (typically 90 percent or less). 
-- Maximum memory that's granted to per query is (Z GB) Y GB * REQUEST_MAX_MEMORY_GRANT_PERCENT/100.

-- The following query options (min_grant_percent and max_grant_percent) apply to Z GB:
-- 
--     Min_grant_percent is guaranteed to the query.
--     Max_grant_percent is the maximum limit.