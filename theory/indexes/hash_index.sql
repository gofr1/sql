USE DEMO;

DROP TABLE IF EXISTS dbo.HashTest;

CREATE TABLE dbo.HashTest (
    Id INTEGER NOT NULL IDENTITY(1,1),
    [Name] VARCHAR(50),
    CreationDate datetime NOT NULL,
    CONSTRAINT [PK_HashTest_Id] PRIMARY KEY NONCLUSTERED (Id)
)
WITH (
    MEMORY_OPTIMIZED = ON, 
    DURABILITY = SCHEMA_AND_DATA
);

--UNIQUE, or can default to Non-Unique.
--NONCLUSTERED, which is the default.
ALTER TABLE dbo.HashTest 
ADD INDEX HI_Name
HASH ([Name]) WITH (BUCKET_COUNT = 64); 
--The maximum number of buckets in hash indexes is 1,073,741,824.
--Usually bucket count = distinct values count

ALTER TABLE dbo.HashTest
ADD CONSTRAINT [DI_HashTest_CreationDate] DEFAULT CURRENT_TIMESTAMP FOR CreationDate;

INSERT INTO dbo.HashTest ([Name]) VALUES 
('although'),('analysis'),('approach'),('actually'),
('anything'),('activity'),('advanced'),('addition'),
('achieved'),('accepted'),('acquired'),('affected'),
('approval'),('audience'),('alliance'),('aircraft'),
('anywhere'),('academic'),('accurate'),('assembly'),
('argument');

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT * 
FROM dbo.HashTest;

INSERT INTO dbo.HashTest ([Name]) VALUES 
('adhesion'),('analogue'),('airfield'),('attendee'),
('assorted'),('allergic'),('academia'),('alkaline'),
('audition'),('armchair'),('additive'),('amenable'),
('animated'),('ambition'),('abnormal'),('airborne'),
('abundant'),('acoustic'),('assemble'),('allocate'),
('adaptive'),('activist'),('affluent'),('antelope'),
('analytic'),('activate'),('altitude'),('automate'),
('aquarium'),('applause'),('arrogant'),('asbestos'),
('annoying');

SELECT *
FROM sys.dm_db_xtp_hash_index_stats;

INSERT INTO dbo.HashTest ([Name]) VALUES 
('business'),('building'),('becoming'),('breaking'),
('birthday'),('bulletin'),('benjamin'),('bachelor'),
('bathroom'),('baseball'),('boundary'),('bacteria'),
('breeding'),('backbone'),('bleeding'),('briefing'),
('brochure'),('backward'),('blessing'),('basement'),
('behavior'),('biblical'),('backdrop'),('bankrupt'),
('beverage'),('ballroom'),('burglary'),('barbecue'),
('ballpark'),('bouncing'),('boutique'),('benedict'),
('breathed'),('backlash'),('backyard'),('beginner'),
('blooming'),('blackout'),('brethren'),('backside'),
('bungalow'),('blockade'),('barefoot'),('breakout'),
('bankcard'),('biennial'),('broccoli'),('biweekly'),
('blizzard'),('blockage'),('bisexual'),('bracelet'),
('breakage'),('bohemian'),('brighten'),('bookshop'),
('buttress'),('barbaric'),('buoyancy'),('bereaved');


SELECT *
FROM sys.dm_db_xtp_hash_index_stats;

INSERT INTO dbo.HashTest ([Name]) VALUES 
('backroom'),('bookcase'),('billiard'),('banality'),
('brackish'),('baseless'),('bootable'),('behemoth'),
('bankable'),('bulkhead'),('bluebird'),('bodywork'),
('boomtown'),('backhand'),('birthing');


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
SET STATISTICS PROFILE ON
GO
SELECT *
FROM dbo.HashTest
wHERE Name IN ('bluebird','blockage')
GO
SET STATISTICS PROFILE OFF
GO

ALTER TABLE dbo.HashTest 
DROP INDEX HI_Name;

ALTER TABLE dbo.HashTest 
ADD INDEX HI_Name
HASH ([Name]) WITH (BUCKET_COUNT = 256); 


SELECT *
FROM sys.dm_db_xtp_hash_index_stats;

SELECT *
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.HashTest');

SELECT * 
FROM sys.hash_indexes;