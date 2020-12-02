USE DEMO;
GO
-- Generate products with some prices

WITH products1 AS (
    SELECT ProductName, BasePrice
    FROM (VALUES 
    ('cap', 2),('t-shirt', 5),('shirt', 8),('pants', 8),('underpants', 3),
    ('blouse', 5),('skirt', 4),('hat', 10),('sweater', 10),('jacket', 12),
    ('coat', 15),('jumper', 11),('blazer', 11),('socks',3 ),('trousers', 10),
    ('undershirt', 4),('pullover', 15),('cardigan', 13),('vest', 19),('jeans', 18),
    ('briefs', 10),('tuxedo', 50),('robe', 16),('dress', 50),('top', 7),
    ('tunic', 8),('leggings', 10),('bikini', 20),('lingerie', 30),('bra', 20),
    ('mittens', 15),('panties', 8),('belt', 10),('gloves', 13),('scarf', 9),
    ('necktie', 12),('handkerchief', 10)
    ) as t(ProductName, BasePrice)
), colours AS (
    SELECT Colour
    FROM (VALUES 
    ('blue'),('red'),('green'),('violet'),('yellow'),
    ('black'),('brown'),('white'),('orange'),('silver'),
    ('pink'),('gray'),('gold'),('crimson'),('aqua'),
    ('bronze'),('charcoal'),('coral'),('cyan'),('fuchsia'),
    ('indigo'),('ivory'),('khaki'),('lime'),('mint'),
    ('navy'), ('olive'), ('pearl'), ('plum'), ('raspberry'),
    ('salmon'), ('slate'), ('terra cotta'), ('wheat')
    ) as t(Colour)    
), sizes AS (
    SELECT Size
    FROM (VALUES 
    ('XS'), ('S'), ('M'), ('L'), ('XL'), ('XXL')
    ) as t(Size)    
), orders AS (
    SELECT NEWID() OrderId,
           1 as lvl,
           10 NumberOfProducts,
           10 StartPoint,
           1 PrevStartPoint
    UNION ALL 
    SELECT NEWID(),
           lvl + 1,
           ABS(CAST(NEWID() AS BINARY(6)) % 10)+1,
           StartPoint + NumberOfProducts,
           StartPoint
    FROM orders
    WHERE lvl < 1000
), ProductWithPrices AS (
    SELECT CONCAT(Colour, ' ', ProductName, ' ', Size) Product,
           BasePrice + (0.00000001 * ABS(CAST(NEWID() AS BINARY(6)) % 100000000)) Price,
           ROW_NUMBER() OVER (ORDER BY NEWID()) as rn
    FROM products1
    CROSS JOIN colours
    CROSS JOIN sizes
)

INSERT INTO dbo.BatchTest
SELECT OrderId,
       pwp.Product,
       ABS(CAST(NEWID() AS BINARY(6)) % 10)+1 as Qty,
       pwp.Price
FROM orders o 
INNER JOIN ProductWithPrices pwp 
    ON pwp.rn > o.PrevStartPoint AND pwp.rn <= o.StartPoint
OPTION (MAXRECURSION 1000)
GO 100