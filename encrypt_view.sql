USE DEMO;

DROP TABLE IF EXISTS dbo.Department;
CREATE TABLE dbo.Department (
    ID INT PRIMARY KEY,
    [Name] VARCHAR(50)
);

INSERT INTO dbo.Department VALUES (1, 'IT');
INSERT INTO dbo.Department VALUES (2, 'HR');
INSERT INTO dbo.Department VALUES (3, 'Sales');

DROP TABLE IF EXISTS dbo.Employee;
CREATE TABLE dbo.Employee (
    ID INT PRIMARY KEY,
    [Name] VARCHAR(50),
    Gender VARCHAR(50),
    BirthDate DATE,
    Salary DECIMAL(18,2),
    DeptID INT
);

INSERT INTO dbo.Employee VALUES (1, 'John',   'Male',   '1996-02-29', 25000, 1);
INSERT INTO dbo.Employee VALUES (2, 'Amanda', 'Female', '1995-05-25', 30000, 2);
INSERT INTO dbo.Employee VALUES (3, 'Viktor', 'Male',   '1995-04-19', 40000, 2);
INSERT INTO dbo.Employee VALUES (4, 'Rosy',   'Female', '1996-03-17', 35000, 3);
INSERT INTO dbo.Employee VALUES (5, 'Nathan', 'Male',   '1997-01-15', 27000, 1);
INSERT INTO dbo.Employee VALUES (6, 'Pixie',  'Female', '1995-07-12', 33000, 2);


DROP VIEW IF EXISTS dbo.vwITDepartmentEmployees;
GO

CREATE VIEW dbo.vwITDepartmentEmployees 
AS 
SELECT ID, 
       [Name],
       Gender, 
       BirthDate, 
       Salary,
       DeptID
FROM dbo.Employee
WHERE DeptID = 1
GO

INSERT INTO dbo.vwITDepartmentEmployees (ID, [Name], Gender, BirthDate, Salary, DeptID)
VALUES (7, 'Andrew', 'Male', '1994-07-24', 45000, 2);

SELECT * FROM dbo.vwITDepartmentEmployees;
SELECT * FROM dbo.Employee; -- New row is inserted

DELETE FROM dbo.Employee WHERE ID = 7;

DROP VIEW IF EXISTS dbo.vwITDepartmentEmployees;
GO

CREATE VIEW dbo.vwITDepartmentEmployees 
AS 
SELECT ID, 
       [Name],
       Gender, 
       BirthDate, 
       Salary,
       DeptID
FROM dbo.Employee
WHERE DeptID = 1
WITH CHECK OPTION 
GO

INSERT INTO dbo.vwITDepartmentEmployees (ID, [Name], Gender, BirthDate, Salary, DeptID)
VALUES (7, 'Andrew', 'Male', '1994-07-24', 45000, 2);
--Now there will be an error

INSERT INTO dbo.vwITDepartmentEmployees (ID, [Name], Gender, BirthDate, Salary, DeptID)
VALUES (7, 'Andrew', 'Male', '1994-07-24', 45000, 1); -- with DeptID = 1 the row will be inserted

SELECT * FROM dbo.vwITDepartmentEmployees;
SELECT * FROM dbo.Employee; -- New row is inserted

DELETE FROM dbo.Employee WHERE ID = 7;



--You can see the text of a view under the text column of the syscomments
SELECT id, 
       ctext, 
       [text] 
FROM SYSCOMMENTS 
WHERE ID = OBJECT_ID('dbo.vwITDepartmentEmployees');

EXEC sp_helptext vwITDepartmentEmployees;

DROP VIEW IF EXISTS dbo.vwITDepartmentEmployees;
GO

CREATE VIEW dbo.vwITDepartmentEmployees 
WITH ENCRYPTION
AS 
SELECT ID, 
       [Name],
       Gender, 
       BirthDate, 
       Salary,
       DeptID
FROM dbo.Employee
WHERE DeptID = 1
WITH CHECK OPTION 
GO

--Now the definition of a view will be ebcrypted
SELECT id, 
       ctext, --NULL
       [text] --NULL
FROM SYSCOMMENTS 
WHERE ID = OBJECT_ID('dbo.vwITDepartmentEmployees');

EXEC sp_helptext vwITDepartmentEmployees; --The text for object 'vwITDepartmentEmployees' is encrypted. 
--You cannot see view definition even from Object Explorer