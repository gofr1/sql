USE [master];  

CREATE LOGIN login_test WITH PASSWORD = 'pa$$w0rd', CHECK_EXPIRATION = OFF;  

GRANT VIEW SERVER STATE TO login_test;  
GO

CREATE TRIGGER connection_limit_trigger  
ON ALL SERVER WITH EXECUTE AS 'login_test'  
FOR LOGON  
AS  
BEGIN  
    IF ORIGINAL_LOGIN()= 'login_test' AND (
        SELECT COUNT(*) 
        FROM sys.dm_exec_sessions  
        WHERE is_user_process = 1 AND  
        original_login_name = 'login_test') > 3  
    ROLLBACK;  
END;  
GO

--Viewing the events that cause a trigger to fire
SELECT *  
FROM sys.server_trigger_events te  
INNER JOIN sys.server_triggers t
    ON T.[object_id] = TE.[object_id]  
WHERE t.name = 'connection_limit_trigger';  

DROP TRIGGER connection_limit_trigger ON ALL SERVER; 

DROP LOGIN login_test;