
USE [master]; 

CREATE DATABASE DEMO;
 
ALTER DATABASE [DEMO] SET RECOVERY SIMPLE ; 

SELECT name,
       state_desc,
       recovery_model_desc
FROM sys.databases


