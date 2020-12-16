USE DEMO;

DECLARE @Data TABLE (
    Name VARCHAR(20), Type VARCHAR(20), Product VARCHAR(20), QuantitySold INT
);

INSERT INTO @Data ( Name, Type, Product, QuantitySold ) VALUES
( 'Walmart', 'Big Store', 'Gummy Bears', 10 ),
( 'Walmart', 'Big Store', 'Toothbrush', 6 ),
( 'Target', 'Small Store', 'Toothbrush', 2 );

SELECT Type = Type.Type,
       Name = [Stores].Name,
       Name = Products.Product,
       QuantitySold = Products.QuantitySold
FROM @Data Products
INNER JOIN @Data Stores
    ON Products.[Name] = Stores.[Name] AND Products.[Type] = Stores.[Type]
       AND Products.[Product] = Stores.[Product] AND Products.[QuantitySold] = Stores.[QuantitySold]
INNER JOIN @Data [Type]
    ON [Type].[Name] = Stores.[Name] AND [Type].[Type] = Stores.[Type]
       AND [Type].[Product] = Stores.[Product] AND [Type].[QuantitySold] = Stores.[QuantitySold]
ORDER BY Type.Type, Stores.Name 
FOR JSON AUTO;


SELECT d.Type,
       (
       SELECT Name "Name",
              (
              SELECT Product "Name",
                     QuantitySold "QuantitySold"
              FROM @Data 
              WHERE dd.Name = Name
              FOR JSON PATH) "Products"
       FROM @Data dd
       WHERE d.Type = dd.Type 
       GROUP BY Name
       FOR JSON PATH) "Stores"
FROM @Data d
GROUP BY d.Type
FOR JSON PATH;

--* [
--*   {
--*     "Type": "Big Store",
--*     "Stores": [
--*       {
--*         "Name": "Walmart",
--*         "Products": [
--*           {
--*             "Name": "Gummy Bears",
--*             "QuantitySold": 10
--*           },
--*           {
--*             "Name": "Toothbrush",
--*             "QuantitySold": 6
--*           }
--*         ]
--*       }
--*       ]
--*   },
--*   {
--*     "Type": "Smaller Store",
--*     "Stores": [
--*       {
--*         "Name": "Target",
--*         "Products": [
--*           {
--*             "Name": "Toothbrush",
--*             "QuantitySold": 2
--*           }
--*         ]
--*       }
--*       ]
--*   }
--* ]

--If data is normalized enough

DECLARE @Types TABLE (
    id int,
    Type nvarchar(20)
);

INSERT INTO @Types VALUES (1, N'Big Store'), (2, N'Small Store');

DECLARE @Stores TABLE (
    id int,
    Name nvarchar(10),
    TypeId int
);

INSERT INTO @Stores VALUES (1, N'Walmart', 1), (2, N'Target', 2), (3, N'Tesco', 2);

DECLARE @Products TABLE (
    id int,
    Name nvarchar(20)
);

INSERT INTO @Products VALUES (1, N'Gummy Bears'), (2, N'Toothbrush'), (3, N'Milk'), (4, N'Ball')

DECLARE @Sales TABLE (
    StoreId int,
    ProductId int,
    QuantitySold int
);

INSERT INTO @Sales VALUES (1, 1, 10), (1, 2, 6), (2, 2, 2), (3, 4, 15), (3, 3, 7);

SELECT Type = Type.Type,
       Name = [Stores].Name,
       Name = Products.Product,
       QuantitySold = Products.QuantitySold
FROM (
    SELECT s.StoreId,
           p.Name Product,
           s.QuantitySold
    FROM @Sales s
    INNER JOIN @Products p 
        ON p.id = s.ProductId
) Products
INNER JOIN @Stores Stores
    ON Stores.Id = Products.StoreId
INNER JOIN @Types [Type]
    ON Stores.TypeId = [Type].id
ORDER BY Type.Type, [Stores].Name
FOR JSON AUTO;


