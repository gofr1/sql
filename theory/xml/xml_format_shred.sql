USE AdventureWorks2017;

--! Combining Node Attributes and Elements
-- Create node attribute values by simply designating column aliases that use the ‘@’ symbol:
SELECT BusinessEntityID AS '@ID', 
       PersonType, 
       Title, 
       FirstName, 
       MiddleName, 
       LastName, 
       Suffix
FROM Person.Person
WHERE BusinessEntityID = 10001
FOR XML PATH('Person');
--* <Person ID="10001">
--*   <PersonType>IN</PersonType>
--*   <FirstName>Carolyn</FirstName>
--*   <LastName>Alonso</LastName>
--* </Person>

--! Include existing XML column
SELECT BusinessEntityID AS '@ID', 
       PersonType, 
       Title, 
       FirstName, 
       MiddleName, 
       LastName, 
       Suffix,
       Demographics -- xml type
FROM Person.Person
WHERE BusinessEntityID = 10001
FOR XML PATH('Person')
-- an existing XML field is created as a nested node element. Note that the XML namespace data is included in the nested node. 
--* <Person ID="10001">
--*   <PersonType>IN</PersonType>
--*   <FirstName>Carolyn</FirstName>
--*   <LastName>Alonso</LastName>
--*   <Demographics>
--*     <IndividualSurvey 
--*       xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey">
--*       <TotalPurchaseYTD>1066.5</TotalPurchaseYTD>
--*       <DateFirstPurchase>2004-01-31Z</DateFirstPurchase>
--*       <BirthDate>1959-07-05Z</BirthDate>
--*       <MaritalStatus>S</MaritalStatus>
--*       <YearlyIncome>25001-50000</YearlyIncome>
--*       <Gender>F</Gender>
--*       <TotalChildren>3</TotalChildren>
--*       <NumberChildrenAtHome>0</NumberChildrenAtHome>
--*       <Education>Graduate Degree</Education>
--*       <Occupation>Clerical</Occupation>
--*       <HomeOwnerFlag>0</HomeOwnerFlag>
--*       <NumberCarsOwned>0</NumberCarsOwned>
--*       <CommuteDistance>0-1 Miles</CommuteDistance>
--*     </IndividualSurvey>
--*   </Demographics>
--* </Person>

--! Shredding XML 
-- To ‘shred’ means to strip the actual data away from the markup tags, and organize it into a relational format. 
-- For example, shredding is what happens when an XML document is imported into a table, when each node value is 
-- mapped to a specific field in the table. 
 	
-- extract (shred) values from XML column nodes
SELECT FirstName,
       MiddleName,
       LastName,
       Demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:Occupation)[1]','varchar(50)') AS Occupation,
       Demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:Education)[1]','varchar(50)') AS Education,
       Demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:HomeOwnerFlag)[1]','bit') AS HomeOwnerFlag,
       Demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:NumberCarsOwned)[1]','int') AS NumberCarsOwned
FROM Person.Person
WHERE BusinessEntityID = 15687;

--* FirstName  MiddleName  LastName  Occupation    Education  HomeOwnerFlag  NumberCarsOwned
--* Elijah     D           Edwards   Professional  Bachelors  1              3

--! XML Namespaces 
-- Declare Namespace once:
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
SELECT FirstName, 
       MiddleName,
       LastName,
       Demographics.value('(/ns:IndividualSurvey/ns:Occupation)[1]','varchar(50)') AS Occupation,
       Demographics.value('(/ns:IndividualSurvey/ns:Education)[1]','varchar(50)') AS Education,
       Demographics.value('(/ns:IndividualSurvey/ns:HomeOwnerFlag)[1]','bit') AS HomeOwnerFlag,
       Demographics.value('(/ns:IndividualSurvey/ns:NumberCarsOwned)[1]','int') AS NumberCarsOwned
FROM Person.Person
WHERE BusinessEntityID = 15687;

--* FirstName  MiddleName  LastName  Occupation    Education  HomeOwnerFlag  NumberCarsOwned
--* Elijah     D           Edwards   Professional  Bachelors  1              3