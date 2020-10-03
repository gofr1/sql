USE DEMO;

DROP TABLE IF EXISTS dbo.DL1;

CREATE TABLE dbo.DL1 (
    id INT
);

INSERT INTO dbo.DL1 VALUES (1);

DROP TABLE IF EXISTS dbo.DL2;

CREATE TABLE dbo.DL2 (
    id INT
);

INSERT INTO dbo.DL2 VALUES (1);

--Let's update row in DL1
--And go to 2nd file and start another transaction
BEGIN TRANSACTION;

UPDATE dbo.DL1 
SET id = 2;

WAITFOR DELAY '00:00:10';

UPDATE dbo.DL2
SET id = 2;

COMMIT TRANSACTION;

SELECT *
FROM dbo.DL1;

SELECT *
FROM dbo.DL2;
