-- PolyBase should be installed at first
-- sudo apt-get install mssql-server-polybase

-- check if PolyBase is installed
SELECT SERVERPROPERTY('IsPolyBaseInstalled') as IsPolyBaseInstalled;

-- enable/disable PolyBase
exec sp_configure @configname = 'polybase enabled', @configvalue = 0;
RECONFIGURE WITH OVERRIDE;

-- check if PolyBase is enabled
SELECT * 
FROM sys.configurations 
WHERE name like '%poly%'