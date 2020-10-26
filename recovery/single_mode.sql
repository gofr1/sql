USE [master]

--! If other users are connected to the database at the time that you set the database to single-user mode, 
--! their connections to the database will be closed without warning.

--! The database remains in single-user mode even if the user that set the option logs off. 
--! At that point, a different user, but only one, can connect to the database.

--! If there are active jobs, either allow the jobs to complete or manually terminate them

ALTER DATABASE [DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- perform backup for example

ALTER DATABASE [DatabaseName] SET MULTI_USER;