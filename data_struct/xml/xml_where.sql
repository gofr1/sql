USE DEMO;

DECLARE @xml xml = '<Details>
  <RelatedDetails>   
    <Name>John Smith</Name>   
    <Position>User</Position>    
    <Relationship>User</Relationship>
    <Salary>4000</Salary>
    <Type>Company</Type>
  </RelatedDetails>
  <RelatedDetails>   
    <Name>Jane Doe</Name>   
    <Position>User</Position>    
    <Relationship>Owner</Relationship>
    <Salary>6500</Salary>
    <Type>Company</Type>
  </RelatedDetails>
  <RelatedDetails>   
    <Name>Nick Valentine</Name>   
    <Position>User</Position>    
    <Relationship>Director</Relationship>
    <Salary>2300</Salary>
    <Type>Company</Type>
  </RelatedDetails>
</Details>';

SELECT t.c.value('(Name)[1]', 'nvarchar(20)') as name
FROM @xml.nodes('/Details/RelatedDetails') as t(c)
WHERE t.c.value('Salary[1]', 'int') > 6000;

SELECT t.c.value('(Name)[1]', 'nvarchar(20)') as name
FROM @xml.nodes('/Details/RelatedDetails') as t(c)
WHERE t.c.exist('Salary[1][. gt 6000]') = 1;

SELECT t.c.value('(Name)[1]', 'nvarchar(20)') as name
FROM @xml.nodes('/Details/RelatedDetails') as t(c)
WHERE t.c.value('Relationship[1]', 'nvarchar(20)') = N'Owner';

SELECT t.c.value('(Name)[1]', 'nvarchar(20)') as name
FROM @xml.nodes('/Details/RelatedDetails') as t(c)
WHERE t.c.exist('Relationship[1][. eq "Owner"]') = 1;

SELECT t.c.value('(Name)[1]', 'nvarchar(50)')
FROM @xml.nodes('/Details/RelatedDetails[Salary[text() > 6000]]') as t(c);

SELECT t.c.value('(Name)[1]', 'nvarchar(50)')
FROM @xml.nodes('/Details/RelatedDetails[Salary[. > 6000]]') as t(c);