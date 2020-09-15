USE AdventureWorks2012;

SET STATISTICS XML, IO, TIME ON;

SELECT AddressID,
       PostalCode
FROM Person.Address
WHERE StateProvinceID = 42;

SET STATISTICS XML, IO, TIME OFF;

--In Clustered Index Seek part of xml plan you can find that lookup was used:
--*<IndexScan Lookup="1" Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore">
--*logical reads 19

DROP INDEX IF EXISTS [idx_Address_StateProvinceID] ON Person.Address;
CREATE NONCLUSTERED INDEX [idx_Address_StateProvinceID] ON Person.Address (StateProvinceID) INCLUDE (PostalCode);

SET STATISTICS XML, IO, TIME ON;

SELECT AddressID,
       PostalCode
FROM Person.Address
WHERE StateProvinceID = 42;

SET STATISTICS XML, IO, TIME OFF;

--Now no lookups but if you will not ise INCLUSE there will be lookup anyway
--*logical reads 2