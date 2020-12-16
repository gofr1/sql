USE DEMO;

--! Switch partition
-- test5fg is currently last and I need to rearrange partitions in order

-- Create table with same structure
DROP TABLE IF EXISTS dbo.IndexTestSwitchPartition;

CREATE TABLE dbo.IndexTestSwitchPartition (
    Id int NOT NULL,
    [Value] varchar(1000),
    CONSTRAINT PK_IndexTestSwitchPartition_Id PRIMARY KEY (Id ASC)
) ON PS5000(Id);

ALTER TABLE dbo.IndexTest
SWITCH PARTITION $PARTITION.PFDemo(5000)
TO dbo.IndexTestSwitchPartition PARTITION $PARTITION.PFDemo(5000);


SELECT COUNT(*) FROM dbo.IndexTest --* 19569

SELECT COUNT(*) FROM dbo.IndexTestSwitchPartition  --*4999

--switch back

ALTER TABLE dbo.IndexTestSwitchPartition
SWITCH PARTITION $PARTITION.PFDemo(5000)
TO dbo.IndexTest PARTITION $PARTITION.PFDemo(5000);


SELECT COUNT(*) FROM dbo.IndexTest --* 24568

SELECT COUNT(*) FROM dbo.IndexTestSwitchPartition  --*0