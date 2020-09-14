USE [master];

--Confirm installation
SELECT SERVERPROPERTY ('IsPolyBaseInstalled') AS IsPolyBaseInstalled;

--Check if PolyBase is enabled
SELECT *
FROM sys.configurations c 
WHERE c.[name] = 'polybase enabled';

--Enable PolyBase
EXEC sp_configure @configname = 'polybase enabled', @configvalue = 1;
RECONFIGURE;
EXEC sp_configure @configname = 'polybase network encryption', @configvalue = 0;
RECONFIGURE;

EXEC master.dbo.sp_MSset_oledb_prop;

DROP DATABASE IF EXISTS PolybaseTesting;

CREATE DATABASE PolybaseTesting;

USE PolybaseTesting;

SELECT * 
FROM sys.external_data_sources;

SELECT * 
FROM sys.external_tables;

