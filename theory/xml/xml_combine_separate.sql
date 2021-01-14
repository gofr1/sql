USE AdventureWorks2017;

--! Combining XML
-- Combine store survey XML data
SELECT TOP 2 [Name], 
       BusinessEntityID AS ID, 
       Demographics.query('/')
FROM Sales.Store AS Store
WHERE SalesPersonID = 282
FOR XML AUTO; -- , ROOT('StoreSurveys') we can add root element

--* <Store Name="Vinyl and Plastic Goods Corporation" ID="312">
--*   <StoreSurvey 
--*     xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey">
--*     <AnnualSales>1500000</AnnualSales>
--*     <AnnualRevenue>150000</AnnualRevenue>
--*     <BankName>Primary Bank &amp; Reserve</BankName>
--*     <BusinessType>OS</BusinessType>
--*     <YearOpened>1980</YearOpened>
--*     <Specialty>Mountain</Specialty>
--*     <SquareFeet>41000</SquareFeet>
--*     <Brands>4+</Brands>
--*     <Internet>DSL</Internet>
--*     <NumberEmployees>43</NumberEmployees>
--*   </StoreSurvey>
--* </Store>
--* <Store Name="Valley Toy Store" ID="324">
--*   <StoreSurvey 
--*     xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey">
--*     <AnnualSales>300000</AnnualSales>
--*     <AnnualRevenue>30000</AnnualRevenue>
--*     <BankName>Reserve Security</BankName>
--*     <BusinessType>BM</BusinessType>
--*     <YearOpened>1979</YearOpened>
--*     <Specialty>Mountain</Specialty>
--*     <SquareFeet>9000</SquareFeet>
--*     <Brands>2</Brands>
--*     <Internet>T1</Internet>
--*     <NumberEmployees>6</NumberEmployees>
--*   </StoreSurvey>
--* </Store>

--! Separating XML 

-- create XML instance of store survey data, using XML variable
DECLARE @xml XML;
 
SET @xml = (
    SELECT TOP 2 [Name], 
           BusinessEntityID AS ID, 
           Demographics.query('/')
    FROM Sales.Store AS Store
    WHERE SalesPersonID = 282
    FOR XML AUTO, ROOT('StoreSurveys')
);

-- separate store survey XML records with namespace declaration
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey' AS ns)
SELECT t.c.value('../@ID','int') AS BusinessEntityID,
       t.c.value('../@Name','varchar(50)') AS StoreName,
       t.c.query('.') AS Demographics
FROM @xml.nodes('/StoreSurveys/Store/ns:StoreSurvey') AS t(c);

-- separate store survey XML records without namespace declaration
SELECT t.c.value('@ID','int') AS BusinessEntityID,
       t.c.value('@Name','varchar(50)') AS StoreName,
       t.c.query('./child::node()') AS Demographics
FROM @xml.nodes('/StoreSurveys/Store') AS t(c);