DECLARE  @ProductDocs TABLE (ProductDoc xml)
 
INSERT INTO @ProductDocs VALUES
('<product>
   <productID>1</productID>
   <productname>tea</productname>
</product>
<product>
   <productID>2</productID>
   <productname>coffee</productname>
</product>')
 
SELECT * FROM @ProductDocs
 
UPDATE @ProductDocs
SET ProductDoc.modify('replace value of (/product[productID=2]/productname/text())[1] with "NewName"')
 
SELECT * FROM @ProductDocs