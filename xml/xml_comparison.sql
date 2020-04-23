declare @myxml xml =
'<Departments>
   <Department>
    <Employees>
      <Employee user="J" id="J10" method="email" date="06/13/2018 08:59">
      </Employee>
      <Employee user="R" id="R10" method="email1" date="07/13/2018 08:59">
      </Employee>
    </Employees>
  </Department>
  <Department>
    <Employees>
      <Employee user="Jason" id="J101" method="email" date="06/13/2018 08:59">
      </Employee>
      <Employee user="Roy" id="R101" method="email1" date="07/13/2018 08:59">
      </Employee>
    </Employees>
  </Department>
</Departments>'

declare @i int = 2

SELECT  t.c.value('@user', 'nvarchar(10)') as [user],
        t.c.value('@id', 'nvarchar(10)') as id,
        t.c.value('@method', 'nvarchar(10)') as method,
        t.c.value('@date', 'nvarchar(10)') as [date]
FROM @myxml.nodes('/Departments/Department/Employees/Employee') as t(c)
WHERE t.c.value('for $i in . return count(/Departments/Department[. << $i]) ', 'int') = @i