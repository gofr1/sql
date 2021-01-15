USE DEMO;

SELECT @@VERSION;

-- First of all make a full install of:
--? sudo apt-get install mssql-mlservices-mlm-py
--? sudo apt-get install mssql-mlservices-mlm-r  (if you need R)

-- Or minimal:
--? sudo apt-get install mssql-mlservices-packages-py
--? sudo apt-get install mssql-mlservices-packages-r

--! Turn 'External Scripts Enabled' server configuration option ON:
EXEC sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE; 

-- If you get 
--! The SQL Server Machine Learning Services End-User License Agreement (EULA) has not been accepted. 
-- You need to add ACCEPT_EULA_ML=Y into mssql-conf and restart SQL Server
--? sudo /opt/mssql/bin/mssql-conf set EULA.accepteulaml Y

-- Also enable outbound network access.
--? sudo /opt/mssql/bin/mssql-conf set extensibility outboundnetworkaccess 1

-- After all this installations you can finaly run Python scripts:
EXECUTE sp_execute_external_script 
    @language = N'Python',
    @script = N'
a = 1
b = 2
c = a/b
d = a*b
print(c, d)
';
--* STDOUT message(s) from external script:
--* 0.5 2

-- Check version
EXECUTE sp_execute_external_script @language = N'Python',
    @script = N'
import sys
print(sys.version)
';
--* STDOUT message(s) from external script:
--* 3.7.2 (default, Dec 29 2018, 06:19:36)
--* [GCC 7.3.0]

-- List packages
EXECUTE sp_execute_external_script @language = N'Python',
    @script = N'
import pkg_resources
import pandas
dists = [str(d) for d in pkg_resources.working_set]
OutputDataSet = pandas.DataFrame(dists)
'
WITH RESULT SETS(([Package] NVARCHAR(max)));
