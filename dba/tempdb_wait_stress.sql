--Now run the test load, using table variables, temp tables, temp tables with named constraints
DECLARE @test TABLE (
    c1 INT NOT NULL, 
    c2 datetime
)

INSERT @test SELECT 1, GETDATE()
--drop table #test
GO 1000

CREATE TABLE #test (
    c1 INT NOT NULL, 
    c2 datetime
)
INSERT #test 
SELECT 1, GETDATE();
DROP TABLE #test;
GO 1000

CREATE TABLE #test (
    c1 INT NOT NULL, 
    c2 datetime, 
    CONSTRAINT pk_test PRIMARY KEY CLUSTERED(c1)
)
INSERT #test SELECT 1, GETDATE();
DROP TABLE #test;
GO 1000