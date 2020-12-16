USE DEMO;  

DROP TABLE IF EXISTS dbo.TestThrow;

CREATE TABLE dbo.TestThrow (
    ID INT NOT NULL,
    CONSTRAINT [PK_TestThrow_id] PRIMARY KEY CLUSTERED (ID)
);  

BEGIN TRY  
    INSERT dbo.TestThrow(ID) VALUES(1);  
    --Force error 2627, Violation of PRIMARY KEY constraint to be raised.  
    INSERT dbo.TestThrow(ID) VALUES(1);  
END TRY  
BEGIN CATCH  
  
    PRINT 'In catch block.';  
    THROW;  
END CATCH;  

--Using FORMATMESSAGE with THROW

EXEC sys.sp_addmessage  
    @msgnum   = 60000, 
    @severity = 16,
    @msgtext  = N'This is a test message with one numeric parameter (%d), one string parameter (%s), and another string parameter (%s).',
    @lang = 'us_english';

DECLARE @msg NVARCHAR(2048) = FORMATMESSAGE(60000, 500, N'First string', N'second string');   
  
THROW 60000, @msg, 1;  

EXEC sys.sp_dropmessage @msgnum = 60000;

SELECT * 
FROM sys.messages 
WHERE message_id = 60000;
