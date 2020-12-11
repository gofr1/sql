USE DEMO;

DECLARE @OnlySpaces NVARCHAR(50) = N'        ' -- 9 spaces
DECLARE @EmptyString NVARCHAR(50) = N'' -- Empty string
DECLARE @UsualText NVARCHAR(50) = N'Some Text' -- Usual text
DECLARE @LeftSpaces NVARCHAR(50) = N'     Text' -- 5 spaces at the beginning
DECLARE @RightSpaces NVARCHAR(50) = N'Some     ' -- 5 trailing spaces

DECLARE @TestSpaces TABLE (
    Tp NVARCHAR(50),
    Txt NVARCHAR(50)
)

INSERT INTO @TestSpaces VALUES
('OnlySpaces', @OnlySpaces),
('EmptyString', @EmptyString),
('UsualText', @UsualText),
('LeftSpaces', @LeftSpaces),
('RightSpaces', @RightSpaces)


SELECT Tp,
       Txt,
       LEN(Txt) as Ln
FROM @TestSpaces

--* Tp             Txt          Ln
--* OnlySpaces              	0
--* EmptyString                 0
--* UsualText      Some Text	9
--* LeftSpaces          Text    9
--* RightSpaces    Some         4

-- Trailing spaces and string that contains only spaces - are trimmed
-- and empty string is equal to "space" string

SELECT IIF(@OnlySpaces = @EmptyString, 'TRUE', 'FALSE')
--* TRUE

-- This query will show everything, even empty string
SELECT *
FROM @TestSpaces
WHERE Txt LIKE '%'

-- This query will show only spaces and empty string ...
SELECT * 
FROM @TestSpaces
WHERE Txt = '' -- ...even you will search for '  ' (two spaces)
