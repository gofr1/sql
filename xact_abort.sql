USE DEMO;

DROP TABLE IF EXISTS dbo.t2;
DROP TABLE IF EXISTS dbo.t1;
GO

CREATE TABLE dbo.t1 (
    a INT NOT NULL,
    CONSTRAINT PK_t1_a PRIMARY KEY CLUSTERED (a)
);
GO

CREATE TABLE dbo.t2 (
    a INT NOT NULL,
    CONSTRAINT FK_t2_t1 FOREIGN KEY (a)
    REFERENCES dbo.t1(a)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
GO

INSERT INTO dbo.t1 VALUES (1);
INSERT INTO dbo.t1 VALUES (3);
INSERT INTO dbo.t1 VALUES (4);
INSERT INTO dbo.t1 VALUES (6);
GO


--Key 2 insert will fail and roll back, but XACT_ABORT was OFF and rest of transaction will succeeded.
SET XACT_ABORT OFF;
GO
BEGIN TRANSACTION;
INSERT INTO dbo.t2 VALUES (1);
INSERT INTO dbo.t2 VALUES (2); -- Foreign key error.
INSERT INTO dbo.t2 VALUES (3);
COMMIT TRANSACTION;
GO

--Key 5 insert error with XACT_ABORT ON will cause all of the second transaction to roll back.
SET XACT_ABORT ON;
GO
BEGIN TRANSACTION;
INSERT INTO dbo.t2 VALUES (4);
INSERT INTO dbo.t2 VALUES (5); -- Foreign key error.
INSERT INTO dbo.t2 VALUES (6);
COMMIT TRANSACTION;
GO


--SELECT will show only keys 1 and 3 added.
SELECT *
FROM dbo.t2;

