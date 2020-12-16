USE DEMO;
GO 

DROP PROCEDURE IF EXISTS dbo.TestRaiseError;
GO

CREATE PROCEDURE dbo.TestRaiseError
AS
BEGIN
    BEGIN TRY  
        -- RAISERROR with severity 11-19 will cause execution to jump to the CATCH block.  
        RAISERROR (
            'Error raised in TRY block.', -- Message text.  
            16, -- Severity.  
            1 -- State.  
        );  
    END TRY  
    BEGIN CATCH  
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT,
                @ErrorProcedure NVARCHAR(128),
                @ErrorLine INT;
    
      
        SELECT @ErrorMessage = ERROR_MESSAGE(),  
               @ErrorSeverity = ERROR_SEVERITY(),  
               @ErrorState = ERROR_STATE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorProcedure = ERROR_PROCEDURE();  -- Works with triggers and SPs
      
        -- Use RAISERROR inside the CATCH block to return error  
        -- information about the original error that caused  
        -- execution to jump to the CATCH block.  
        RAISERROR (
            @ErrorMessage, -- Message text.  
            @ErrorSeverity, -- Severity.  
            @ErrorState, -- State.  
            @ErrorProcedure,
            @ErrorLine
        );  
    END CATCH
END
GO

EXEC dbo.TestRaiseError;