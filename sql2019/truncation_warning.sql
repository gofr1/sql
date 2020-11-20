USE DEMO;

DROP TABLE IF EXISTS #temp;

CREATE TABLE #temp (
    SomeText varchar(10)
);

INSERT INTO #temp VALUES ('Some random text'),('One more random text');

--* Msg 2628, Level 16, State 1, Line 9
--* String or binary data would be truncated in table 'tempdb.dbo.#temp_..._000000000003', column 'SomeText'. Truncated value: 'Some rando'. 