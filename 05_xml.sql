USE DEMO;

DECLARE @xmlRaw varchar(1000),
        @xmlInMemory INT;

SET @xmlRaw = '<person>
    <firstname>Lev</firstname>
    <lastname>Tolstoy</lastname>
</person>';

EXEC sp_xml_preparedocument @xmlInMemory OUTPUT, @xmlRaw;

SELECT *
FROM OPENXML (@xmlInMemory, '/person',2)
WITH (firstname varchar(50), lastname varchar(50));

EXEC sp_xml_removedocument @xmlInMemory;