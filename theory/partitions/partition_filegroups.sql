USE [master];

ALTER DATABASE DEMO
ADD FILEGROUP test1fg;

ALTER DATABASE DEMO
ADD FILE
(
    NAME = test1dat1,
    FILENAME = '/var/opt/mssql/data/t1dat1.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
),  
(  
    NAME = test1dat2,
    FILENAME = '/var/opt/mssql/data/t1dat2.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)  
TO FILEGROUP test1fg;

ALTER DATABASE DEMO
ADD FILEGROUP test2fg;

ALTER DATABASE DEMO
ADD FILE
(
    NAME = test2dat1,
    FILENAME = '/var/opt/mssql/data/t2dat1.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)  
TO FILEGROUP test2fg;


ALTER DATABASE DEMO
ADD FILEGROUP test3fg;

ALTER DATABASE DEMO
ADD FILE
(
    NAME = test3dat1,
    FILENAME = '/var/opt/mssql/data/t3dat1.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)  
TO FILEGROUP test3fg;


ALTER DATABASE DEMO
ADD FILEGROUP test4fg;

ALTER DATABASE DEMO
ADD FILE
(
    NAME = test4dat1,
    FILENAME = '/var/opt/mssql/data/t4dat1.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)  
TO FILEGROUP test4fg;

ALTER DATABASE DEMO
ADD FILEGROUP test5fg;

ALTER DATABASE DEMO
ADD FILE
(
    NAME = test5dat1,
    FILENAME = '/var/opt/mssql/data/t5dat1.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)  
TO FILEGROUP test5fg;

--Check files
SELECT * FROM sys.database_files