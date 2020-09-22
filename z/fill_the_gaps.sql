USE DEMO;

DROP TABLE IF EXISTS dbo.FillTheGaps;

CREATE TABLE dbo.FillTheGaps (
  [age] int,
  [period] int,
  [year] int
);

INSERT INTO dbo.FillTheGaps VALUES
(0, NULL, NULL),
(1, NULL, NULL),
(2, NULL, NULL),
(3, NULL, NULL),
(4, NULL, NULL),
(5, NULL, NULL),
(6, NULL, NULL),
(7, NULL, NULL),
(8, NULL, NULL),
(9, NULL, NULL),
(10, NULL, NULL),
(11, NULL, NULL),
(12, NULL, NULL),
(13, NULL, NULL),
(14, NULL, NULL),
(15, NULL, NULL),
(16, NULL, NULL),
(17, NULL, NULL),
(18, NULL, NULL),
(19, NULL, NULL),
(20, NULL, NULL),
(21, 46, 2065),
(22, NULL, NULL),
(23, NULL, NULL),
(24, NULL, NULL),
(25, NULL, NULL),
(26, 51, 2070),
(27, NULL, NULL),
(28, NULL, NULL),
(29, NULL, NULL),
(30, NULL, NULL);

SELECT age,
       MAX([period] - [age]) over () + [age] as [period],
       MAX([year] - [age]) over () + [age] as [year]
from dbo.FillTheGaps;