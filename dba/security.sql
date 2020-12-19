USE DEMO;

-- Returns a list of the permissions effectively granted to the principal on a securable. 

-- Is the name of the class of securable for which permissions are listed. securable_class is a sysname. 
-- securable_class must be one of the following: 
-- APPLICATION ROLE, ASSEMBLY, ASYMMETRIC KEY, CERTIFICATE, CONTRACT, DATABASE, ENDPOINT, FULLTEXT CATALOG, 
-- LOGIN, MESSAGE TYPE, OBJECT, REMOTE SERVICE BINDING, ROLE, ROUTE, SCHEMA, SERVER, SERVICE, SYMMETRIC KEY, 
-- TYPE, USER, XML SCHEMA COLLECTION.

-- Listing effective permissions on the server
SELECT * FROM fn_my_permissions(NULL, 'SERVER');  

-- Listing effective permissions on the database
SELECT * FROM fn_my_permissions(NULL, 'DATABASE');  

-- Listing effective permissions on a view
SELECT * FROM fn_my_permissions('dbo.IndexTest', 'OBJECT')


-- Testing on guest user
GRANT CONNECT TO guest;
GRANT SELECT TO guest;

-- Listing effective permissions of another user
EXECUTE AS USER = 'guest';  
SELECT * FROM fn_my_permissions('dbo.IndexTest', 'OBJECT'); 
REVERT; 

REVOKE SELECT TO guest;
REVOKE CONNECT TO guest;

-- Listing effective permissions on a database user
SELECT * FROM fn_my_permissions('guest', 'USER');  
