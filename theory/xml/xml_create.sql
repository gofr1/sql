USE AdventureWorks2017;

--! Creating XML 
-- Create XML using FOR XML AUTO
-- It creates one node for each record returned by the SELECT clause
SELECT BusinessEntityID, 
       PersonType, 
       Title, 
       FirstName, 
       MiddleName, 
       LastName, 
       Suffix
FROM Person.Person
WHERE BusinessEntityID = 10001
FOR XML AUTO;
--* <Person.Person BusinessEntityID="10001" PersonType="IN" FirstName="Carolyn" LastName="Alonso"/>

-- To specify that the values be created as node elements, not attributes, we can additionally specify the ELEMENTS argument
SELECT BusinessEntityID, 
       PersonType, 
       Title, 
       FirstName, 
       MiddleName, 
       LastName, 
       Suffix
FROM Person.Person
WHERE BusinessEntityID = 10001
FOR XML AUTO, ELEMENTS;
--* <Person.Person>
--*   <BusinessEntityID>10001</BusinessEntityID>
--*   <PersonType>IN</PersonType>
--*   <FirstName>Carolyn</FirstName>
--*   <LastName>Alonso</LastName>
--* </Person.Person>

-- Create XML using FOR XML PATH
SELECT  BusinessEntityID, 
        PersonType, 
        Title, 
        FirstName, 
        MiddleName, 
        LastName, 
        Suffix
FROM Person.Person
WHERE BusinessEntityID = 10001
FOR XML PATH ('Person'); -- root element
--* <Person>
--*   <BusinessEntityID>10001</BusinessEntityID>
--*   <PersonType>IN</PersonType>
--*   <FirstName>Carolyn</FirstName>
--*   <LastName>Alonso</LastName>
--* </Person>