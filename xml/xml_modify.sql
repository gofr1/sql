USE DEMO;

DECLARE  @ProductDocs TABLE (ProductDoc xml);
 
INSERT INTO @ProductDocs VALUES
('<product>
   <productID>1</productID>
   <productname>tea</productname>
</product>
<product>
   <productID>2</productID>
   <productname>coffee</productname>
</product>');
 
SELECT * FROM @ProductDocs;
 
UPDATE @ProductDocs
SET ProductDoc.modify('replace value of (/product[productID=2]/productname/text())[1] with "NewName"');
 
SELECT * FROM @ProductDocs;

--delete an XML node based on a child's value with conditions
DECLARE @x xml = N'<root>
<child1>
    <child2>
        <child3>Value1</child3>
        <child3>Value2</child3>
        <child3>Value3</child3>
    </child2>
</child1>
<child1>
    <child2>
        <child3>Value1</child3>
        <child3>Value4</child3>
        <child3>Value5</child3>
    </child2>
</child1>
<child1>
    <child2>
        <child3>Value5</child3>
        <child3>Value2</child3>
        <child3>Value6</child3>
    </child2>
</child1>
</root>'


SET @x.modify('delete /root/child1/child2[contains(.,"Value1") and (not(contains(.,"Value2")) or not(contains(.,"Value3")))]')

SELECT @x