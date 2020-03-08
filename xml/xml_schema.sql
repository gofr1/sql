USE DEMO;

CREATE XML SCHEMA COLLECTION dbo.DemoXMLSchema
AS
'<?xml version="1.0" encoding="UTF-8" ?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">  
    <xs:element name="person">  
        <xs:complexType>  
            <xs:sequence>  
                <xs:element name="firstname" minOccurs="1" type="xs:string"/>  
                <xs:element name="lastname" minOccurs="1" type="xs:string"/>  
            </xs:sequence>  
        </xs:complexType>  
    </xs:element>  
</xs:schema>';

DROP TABLE IF EXISTS dbo.XMLSchemaTest;

CREATE TABLE dbo.XMLSchemaTest (
    untyped xml NOT NULL,
    typed xml (CONTENT dbo.DemoXMLSchema) NOT NULL,
    justText VARCHAR(1000) NOT NULL
);

INSERT INTO dbo.XMLSchemaTest  (untyped, typed, justText) VALUES 
('<person>
    <firstname>Lev</firstname>
    <lastname>Tolstoy</lastname>
</person>',  -- in typed column we insert xml that is validated by schema
-- in this example insertion runs fine
'<person>
    <firstname>Lev</firstname>
    <lastname>Tolstoy</lastname>
</person>',
'<person>
    <firstname>Lev</firstname>
    <lastname>Tolstoy</lastname>
</person>');

SELECT * FROM dbo.XMLSchemaTest;


INSERT INTO dbo.XMLSchemaTest  (untyped, typed, justText) VALUES 
('<person>
    <firstname>Lev</firstname>
</person>', --here we removed lastname tag? therefor validating wil fail
-- and insertion will not occure
'<person>
    <firstname>Lev</firstname>
</person>',
'<person>
    <firstname>Lev</firstname>
</person>');