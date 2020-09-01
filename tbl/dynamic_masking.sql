USE DEMO;

DROP TABLE IF EXISTS dbo.Emails;

CREATE TABLE dbo.Emails (
    Id int IDENTITY(1,1) NOT NULL,
    Email varchar(50)  MASKED WITH (FUNCTION = 'email()') NOT NULL,
    CONSTRAINT PK_EmailsId PRIMARY KEY CLUSTERED (Id)
);

INSERT INTO dbo.Emails (Email) VALUES
('example@domain.com');

SELECT * FROM dbo.Emails;

EXECUTE AS USER = 'guest'

SELECT * FROM dbo.Emails

REVERT;

GRANT CONNECT TO guest;
GRANT SELECT TO guest;
GRANT UNMASK TO guest;

REVOKE UNMASK TO guest;
REVOKE SELECT TO guest;
REVOKE CONNECT TO guest;
