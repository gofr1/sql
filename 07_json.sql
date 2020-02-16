USE DEMO;
-- from tabular to JSON
SELECT FirstName,
       LastName
FROM dbo.Person
FOR JSON AUTO;

-- from JSON to tabular
DECLARE @json VARCHAR(200);

SET @json = '[
    {"firstname":"Lev", "lastname":"Tolstoy"},
    {"firstname":"Fedor", "lastname":"Dostoevsky"}
]'

SELECT *
FROM OPENJSON (@json)
WITH (firstname varchar(50) '$.firstname',
lastname varchar(50) '$.lastname'
)

--storing JSON
DROP TABLE IF EXISTS dbo.JSONTest;

CREATE TABLE dbo.JSONTest (
    JSONData varchar(1000) NOT NULL
);

ALTER TABLE dbo.JSONTest
ADD CONSTRAINT CheckJSON
CHECK (ISJSON(JSONData)>0);

INSERT INTO dbo.JSONTest (JSONData) VALUES ('[
    {"firstname":"Lev", "lastname":"Tolstoy"},
    {"firstname":"Fedor", "lastname":"Dostoevsky"}
]')

SELECT JSONData
FROM dbo.JSONTest