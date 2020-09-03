USE DEMO;

--EXCEPT returns distinct rows from the left input query that aren't output by the right input query.
--INTERSECT returns distinct rows that are output by both the left and right input queries operator.

DROP TABLE IF EXISTS dbo.TableOne;
DROP TABLE IF EXISTS dbo.TableTwo;

CREATE TABLE dbo.TableOne (
    Col1 varchar(200),
    Col2 varchar(200),
    Col3 varchar(200)
);

CREATE TABLE dbo.TableTwo (
    Col1 varchar(200),
    Col2 varchar(200),
    Col3 varchar(200)
);

INSERT INTO dbo.TableOne (Col1, Col2, Col3)
VALUES ('Some dummy text', '', 'Hello');

INSERT INTO dbo.TableTwo (Col1, Col2, Col3)
VALUES ('Some dummy text', '', 'Hello');

SELECT * 
FROM dbo.TableOne
EXCEPT
SELECT * 
FROM dbo.TableTwo; -- No rows

SELECT * 
FROM dbo.TableOne
INTERSECT
SELECT * 
FROM dbo.TableTwo; -- 1 row

INSERT INTO dbo.TableOne (Col1, Col2, Col3)
VALUES ('Some more dummy text', 'Hi', ''); 
-- After this there will be one row in except query

--What about NULLS
INSERT INTO dbo.TableOne (Col1, Col2, Col3)
VALUES ('Some dummy text', NULL, 'Hello');

INSERT INTO dbo.TableTwo (Col1, Col2, Col3)
VALUES ('Some dummy text', NULL, 'Hello');


SELECT * 
FROM dbo.TableOne
EXCEPT
SELECT * 
FROM dbo.TableTwo; -- 1 row with Hi in Col2

SELECT * 
FROM dbo.TableOne
INTERSECT
SELECT * 
FROM dbo.TableTwo; -- 2 rows

INSERT INTO dbo.TableOne (Col1, Col2, Col3)
VALUES ('Some dummy text', NULL, 'Ahoj');

INSERT INTO dbo.TableTwo (Col1, Col2, Col3)
VALUES ('Some dummy text', 'Ahoj', NULL);