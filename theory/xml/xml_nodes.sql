USE AdventureWorks2017;

--! XQuery nodes() method 
-- is another option that allows us to specify a particular node set in which to look for the desired child nodes:
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
SELECT FirstName, 
       MiddleName,
       LastName,
       t.c.value('ns:Occupation[1]','varchar(50)') AS Occupation,
       t.c.value('ns:Education[1]','varchar(50)') AS Education,
       t.c.value('ns:HomeOwnerFlag[1]','bit') AS HomeOwnerFlag,
       t.c.value('ns:NumberCarsOwned[1]','int') AS NumberCarsOwned
FROM Person.Person
CROSS APPLY Demographics.nodes('/ns:IndividualSurvey') AS t(c)
WHERE BusinessEntityID = 15687;
-- We’ve used the nodes() method to drill down (one level) to the location of the ‘IndividualSurvey‘ node, 
-- and then returned the actual values via the XQuery value() method.
--* FirstName  MiddleName  LastName  Occupation    Education  HomeOwnerFlag  NumberCarsOwned
--* Elijah     D           Edwards   Professional  Bachelors  1              3

--! Check efficiency of nodes() vs standard

SET STATISTICS IO, TIME, PROFILE, XML ON;

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

--* CPU time = 4 ms, elapsed time = 5 ms. 
--* Scan count 4, logical reads 16

-- using nodes() method (less eficient)
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
SELECT FirstName, 
       MiddleName,
       LastName,
       t.c.value('ns:Occupation[1]','varchar(50)') AS Occupation,
       t.c.value('ns:Education[1]','varchar(50)') AS Education,
       t.c.value('ns:HomeOwnerFlag[1]','bit') AS HomeOwnerFlag,
       t.c.value('ns:NumberCarsOwned[1]','int') AS NumberCarsOwned
FROM Person.Person
CROSS APPLY Demographics.nodes('/ns:IndividualSurvey') AS t(c)
WHERE BusinessEntityID = 15687;

--* CPU time = 7 ms, elapsed time = 6 ms. 
--* Scan count 5, logical reads 19

SET STATISTICS IO, TIME, PROFILE, XML OFF;
