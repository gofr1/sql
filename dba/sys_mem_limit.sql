USE [master];

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'max server memory', 4096;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
