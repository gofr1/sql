USE [master];

DROP DATABASE IF EXISTS DEMO_snapshot;

CREATE DATABASE DEMO_snapshot ON  
(NAME = DEMO, FILENAME = '/var/opt/mssql/data/DEMO_snapshot.ss' ),
--All files must be specified for database snapshot creation. Missing the file "test1dat1". 
--So lets specify all files
(NAME = test1dat1, FILENAME = '/var/opt/mssql/data/t1dat1_snapshot.ss'),
(NAME = test1dat2, FILENAME = '/var/opt/mssql/data/t1dat2_snapshot.ss'),
(NAME = test2dat1, FILENAME = '/var/opt/mssql/data/t2dat1_snapshot.ss'),
(NAME = test3dat1, FILENAME = '/var/opt/mssql/data/t3dat1_snapshot.ss'),
(NAME = test4dat1, FILENAME = '/var/opt/mssql/data/t4dat1_snapshot.ss'),
(NAME = test5dat1, FILENAME = '/var/opt/mssql/data/t5dat1_snapshot.ss'),
(NAME = test6dat1, FILENAME = '/var/opt/mssql/data/t6dat1_snapshot.ss')
AS SNAPSHOT OF DEMO;  
--filestream/in-memory was automatically created

