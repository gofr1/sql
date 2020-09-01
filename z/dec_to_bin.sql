DECLARE @decValue int = 256,
        @binVal nvarchar(100) = N''

WHILE @decValue > 0
BEGIN
    SET @binVal = @binVal + CAST(@decValue%2 as nvarchar(1))
    SET @decValue = @decValue/2
END

SELECT REVERSE(@binVal)
