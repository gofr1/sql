-- You need to create an account in Azure AD and make it an instance AD Administrator.
-- This Account should have roles (at least when I add them - it worked):
--  SQL Security Manager
--  Contributor
-- After that connect to the instance and run this to add another AD user to a reader group:

CREATE USER [name@domain.com] FROM EXTERNAL PROVIDER;

ALTER ROLE db_datareader ADD MEMBER [name@domain.com]; 
-- After that you can connect via name@domain.com user to SQL Server