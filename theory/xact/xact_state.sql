USE DEMO;  
GO  

DROP TABLE IF EXISTS dbo.tblSub;
DROP TABLE IF EXISTS dbo.tblMain;

CREATE TABLE dbo.tblMain (
    id int identity(1,1) NOT NULL,
    Something varchar(100) NOT NULL,
    CONSTRAINT [PK_tblMain_id] PRIMARY KEY CLUSTERED (id)
);

CREATE TABLE dbo.tblSub (
    id int identity(1,1) NOT NULL,
    MainId int NOT NULL,
    CONSTRAINT [PK_tblSub_id] PRIMARY KEY CLUSTERED (id),
    CONSTRAINT [FK_tblSub_tblMain_id] FOREIGN KEY (MainId) REFERENCES dbo.tblMain(id)
);

INSERT INTO dbo.tblMain (Something) VALUES 
('One'), ('Two'), ('Three');

INSERT INTO dbo.tblSub (MainId) 
SELECT Id FROM dbo.tblMain;

SELECT * FROM dbo.tblMain;
SELECT * FROM dbo.tblSub;

-- SET XACT_ABORT ON will render the transaction uncommittable  
-- when the constraint violation occurs.  
SET XACT_ABORT ON;  
  
BEGIN TRY  
    BEGIN TRANSACTION;  
        -- A FOREIGN KEY constraint exists on this table. This   
        -- statement will generate a constraint violation error.  
        DELETE FROM dbo.tblMain 
        WHERE Something = 'Two';  
  
    -- If the delete operation succeeds, commit the transaction. The CATCH  
    -- block will not execute.  
    COMMIT TRANSACTION;  
END TRY  
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;
    -- Test XACT_STATE for 0, 1, or -1.  
    -- If 1, the transaction is committable.  
    -- If -1, the transaction is uncommittable and should   
    --     be rolled back.  
    -- XACT_STATE = 0 means there is no transaction and  
    --     a commit or rollback operation would generate an error.  
  
    -- Test whether the transaction is uncommittable.  
    IF (XACT_STATE()) = -1  
    BEGIN 
        SELECT @ErrorMessage = ERROR_MESSAGE() + '  The transaction is in an uncommittable state. Rolling back transaction.',  
               @ErrorSeverity = ERROR_SEVERITY(),  
               @ErrorState = ERROR_STATE()

        RAISERROR (
            @ErrorMessage,
            @ErrorSeverity,  
            @ErrorState
        );    
        ROLLBACK TRANSACTION;  
    END;  
  
    -- Test whether the transaction is active and valid.  
    IF (XACT_STATE()) = 1  
    BEGIN  
        PRINT 'The transaction is committable. Committing transaction.'  
        COMMIT TRANSACTION;     
    END;  
END CATCH;  
GO  