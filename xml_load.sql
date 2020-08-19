USE DEMO;

--Reading from file
SELECT Customer.query('Document').value('.', 'VARCHAR(20)') Document,
       Customer.query('Name').value('.', 'VARCHAR(50)') [Name],
       Customer.query('Address').value('.', 'VARCHAR(50)') [Address],
       Customer.query('Profession').value('.', 'VARCHAR(50)') Profession
FROM (
    SELECT CAST(x AS xml)
    FROM OPENROWSET(BULK '/var/opt/mssql/load/xml_sample.xml', SINGLE_BLOB) AS t(x)
    ) AS t(x)
CROSS APPLY x.nodes('Customers/Customer') AS x(Customer);

--Read from xml with the help of preparedocumnet and schema
DECLARE @xml varchar(max) = 
'<?xml version="1.0" encoding="UTF-8"?>
<ETS xsi:schemaLocation="http://www.caodc.ca/ETS/v3 ETS_v3.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.caodc.ca/ETS/v3">
<WellTours>
<WellTour>
<LicenseNo>001</LicenseNo>
<WellName>75-998</WellName>
</WellTour>
<WellTour>
<LicenseNo>007</LicenseNo>
<WellName>14-172</WellName>
</WellTour>
</WellTours>
</ETS>';

DECLARE @hdoc int;

EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml, '<x:ETS xmlns:x="http://www.caodc.ca/ETS/v3" />';

SELECT *
FROM OPENXML (@hdoc, 'x:ETS/x:WellTours/x:WellTour',2)
WITH (
        WellName varchar(100) 'x:WellName',
        LicenseNo varchar(100) 'x:LicenseNo');

EXEC sp_xml_removedocument @hdoc;