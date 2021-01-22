SELECT DB_NAME();

DROP TABLE dbo.HashDistribution;
DROP TABLE dbo.RoundRobinDistribution;

--! Hash
-- A hash-distributed table distributes table rows across the Compute nodes by using 
-- a deterministic hash function to assign each row to one distribution.
CREATE TABLE dbo.HashDistribution (
    Id int NOT NULL,
    SomeDate date NOT NULL,
    SomeInfo varchar(2000) NULL,
    SomeStatus bit NOT NULL
)
WITH (
    DISTRIBUTION = HASH([SomeDate])
);

-- Check distribution of values
DBCC PDW_SHOWSPACEUSED('dbo.HashDistribution')

--! Round-Robin
-- A round-robin distributed table distributes table rows evenly across all distributions. 
-- The assignment of rows to distributions is random. Unlike hash-distributed tables, 
-- rows with equal values are not guaranteed to be assigned to the same distribution.
CREATE TABLE dbo.RoundRobinDistribution (
    Id int NOT NULL,
    SomeDate date NOT NULL,
    SomeInfo varchar(2000) NULL,
    SomeStatus bit NOT NULL
)
WITH (
    DISTRIBUTION = ROUND_ROBIN
);

-- Check distribution of values
DBCC PDW_SHOWSPACEUSED('dbo.RoundRobinDistribution')