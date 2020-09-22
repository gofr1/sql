USE [main-db];

DROP TABLE IF EXISTS dbo.test;

CREATE TABLE dbo.test (
    id INT IDENTITY(1,1),
    name varchar(512),
    CONSTRAINT PK_test_id PRIMARY KEY  (id)
);

INSERT INTO dbo.test (name) VALUES
('John Wick'), ('Sherlock Holmes'), ('Wade Wilson');

SELECT *
FROM dbo.test;
