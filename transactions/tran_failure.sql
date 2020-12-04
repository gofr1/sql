USE DEMO;
GO

DROP TABLE IF EXISTS dbo.TranFailTest;
GO

CREATE TABLE dbo.TranFailTest (
    Something int NOT NULL
);
GO

CREATE OR ALTER PROCEDURE dbo.TranFail 
AS
BEGIN

    INSERT INTO dbo.TranFailTest VALUES (1), (2);

    UPDATE dbo.TranFailTest
    SET Something = NULL
    WHERE Something = 2;

END
GO

EXEC dbo.TranFail;
--! Msg 515, Level 16, State 2, Procedure dbo.TranFail, Line 8
--! Cannot insert the value NULL into column 'Something', table 'DEMO.dbo.TranFailTest'; column does not allow nulls. UPDATE fails. 

SELECT * FROM dbo.TranFailTest;
--* Something
--* 1
--* 2
-- So INSERT statemant is executed and UPDATE fails

TRUNCATE TABLE dbo.TranFailTest;
GO
-- Now let's put stored procedure into transaction

BEGIN TRANSACTION;
EXEC dbo.TranFail;
COMMIT TRANSACTION;
--! Msg 515, Level 16, State 2, Procedure dbo.TranFail, Line 8
--! Cannot insert the value NULL into column 'Something', table 'DEMO.dbo.TranFailTest'; column does not allow nulls. UPDATE fails. 

SELECT * FROM dbo.TranFailTest;
--* Something
--* 1
--* 2

TRUNCATE TABLE dbo.TranFailTest;
GO
-- Now let's put stored procedure code into transaction

CREATE OR ALTER PROCEDURE dbo.TranFail 
AS
BEGIN

    BEGIN TRANSACTION;

    INSERT INTO dbo.TranFailTest VALUES (1), (2);

    UPDATE dbo.TranFailTest
    SET Something = NULL
    WHERE Something = 2;
    
    COMMIT TRANSACTION;

END
GO

EXEC dbo.TranFail;
--! Msg 515, Level 16, State 2, Procedure dbo.TranFail, Line 8
--! Cannot insert the value NULL into column 'Something', table 'DEMO.dbo.TranFailTest'; column does not allow nulls. UPDATE fails. 

SELECT * FROM dbo.TranFailTest;
--* Something
--* 1
--* 2

-- So no cjhanges in execution

TRUNCATE TABLE dbo.TranFailTest;
GO
-- Now let's try adding XACT_ABORT on


CREATE OR ALTER PROCEDURE dbo.TranFail 
AS
BEGIN
    -- Specifies whether SQL Server automatically rolls back the current transaction 
    --when a Transact-SQL statement raises a run-time error.
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    INSERT INTO dbo.TranFailTest VALUES (1), (2);

    UPDATE dbo.TranFailTest
    SET Something = NULL
    WHERE Something = 2;
    
    COMMIT TRANSACTION;

END
GO

EXEC dbo.TranFail;
--! Msg 515, Level 16, State 2, Procedure dbo.TranFail, Line 8
--! Cannot insert the value NULL into column 'Something', table 'DEMO.dbo.TranFailTest'; column does not allow nulls. UPDATE fails. 

SELECT * FROM dbo.TranFailTest;
--* Something

--? Aha, here it roolbacked everything

TRUNCATE TABLE dbo.TranFailTest;
GO
-- Let's try error handling with rollback

CREATE OR ALTER PROCEDURE dbo.TranFail 
AS
BEGIN

    BEGIN TRANSACTION;

    INSERT INTO dbo.TranFailTest VALUES (1), (2);

    UPDATE dbo.TranFailTest
    SET Something = NULL
    WHERE Something = 2;
    
    IF (@@ERROR <> 0) ROLLBACK TRANSACTION ELSE COMMIT TRANSACTION;

END
GO

EXEC dbo.TranFail;
--! Msg 515, Level 16, State 2, Procedure dbo.TranFail, Line 8
--! Cannot insert the value NULL into column 'Something', table 'DEMO.dbo.TranFailTest'; column does not allow nulls. UPDATE fails. 

SELECT * FROM dbo.TranFailTest;
--* Something

--? Aha, once again it roolbacked everything


TRUNCATE TABLE dbo.TranFailTest;
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

BEGIN TRY
BEGIN TRANSACTION

INSERT INTO dbo.TranFailTest VALUES (1), (2);

UPDATE dbo.TranFailTest
SET Something = NULL
WHERE Something = 2;

COMMIT TRANSACTION
END TRY

BEGIN CATCH 
SELECT ERROR_MESSAGE(), ERROR_NUMBER()
ROLLBACK TRANSACTION
END CATCH

-- In table mode
--? Cannot insert the value NULL into column 'Something', table 'DEMO.dbo.TranFailTest'; column does not allow nulls. UPDATE fails.	515

SELECT * FROM dbo.TranFailTest;
--* Something
-- And everything is rollbacked

TRUNCATE TABLE dbo.TranFailTest;
GO
-- Let's try error handling with rollback

CREATE OR ALTER PROCEDURE dbo.TranFail 
AS
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION
        
        INSERT INTO dbo.TranFailTest VALUES (1), (2);
        
        UPDATE dbo.TranFailTest
        SET Something = NULL
        WHERE Something = 2;
        
        COMMIT TRANSACTION
    END TRY
    
    BEGIN CATCH 
        SELECT ERROR_NUMBER() ErrNum,
               ERROR_MESSAGE() ErrMes
        
        ROLLBACK TRANSACTION
    END CATCH

END
GO

EXEC dbo.TranFail;
--* ErrNum  ErrMes
--* 515     Cannot insert the value NULL into column 'Something', table 'DEMO.dbo.TranFailTest'; column does not allow nulls. UPDATE fails.

SELECT * FROM dbo.TranFailTest;
--* Something

