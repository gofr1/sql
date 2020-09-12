USE [master];

--SQL Server Resource Governor is a feature that you can use to manage SQL Server workload and system resource consumption
--Returns information about the current resource pool state, the current configuration of resource pools, and resource pool statistics.
SELECT pool_id,
       [name],
       max_memory_kb/1024.0 as max_memory_mb,
       used_memory_kb/1024.0 as used_memory_mb,
       target_memory_kb/1024.0 as target_memory_mb,
       cache_memory_kb/1024.0 as cache_memory_mb,
       compile_memory_kb/1024.0 as compile_memory_mb,
       read_bytes_total/1024.0/1024.0 as read_megabytes_total,
       total_cpu_active_ms,
       total_cpu_delayed_ms,
       total_memgrant_count,
       active_memgrant_kb/1024.0 as active_memgrant_mb,
       used_memgrant_kb/1024.0 as used_memgrant_mb
FROM sys.dm_resource_governor_resource_pools  

--The command provides a snapshot of the current memory status of Microsoft SQL Server. 
DBCC MEMORYSTATUS