USE graphdemo;

-- The SHORTEST_PATH function lets you find:
-- + A shortest path between two given nodes/entities
-- + Single source shortest path(s).
-- + Shortest path from multiple source nodes to multiple target nodes.

-- Find shortest path between 2 people
SELECT PersonName,
       Friends
FROM (
    SELECT Person1.name AS PersonName, 
           STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
           LAST_VALUE(Person2.name) WITHIN GROUP (GRAPH PATH) AS LastNode
    FROM
        Person AS Person1,
        friendOf FOR PATH AS fo,
        Person FOR PATH  AS Person2
    WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
    AND Person1.name = 'Jacob'
) AS Q
WHERE Q.LastNode = 'Alice';

-- Find shortest path from a given node to all other nodes in the graph.
SELECT Person1.name AS PersonName, 
       STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM
    Person AS Person1,
    friendOf FOR PATH AS fo,
    Person FOR PATH  AS Person2
WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
AND Person1.name = 'Jacob';

-- Count the number of hops/levels traversed to go from one person to another in the graph.
SELECT PersonName,
       Friends,
       levels
FROM (	
    SELECT Person1.name AS PersonName, 
           STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
           LAST_VALUE(Person2.name) WITHIN GROUP (GRAPH PATH) AS LastNode,
           COUNT(Person2.name) WITHIN GROUP (GRAPH PATH) AS levels
    FROM
        Person AS Person1,
        friendOf FOR PATH AS fo,
        Person FOR PATH  AS Person2
    WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
    AND Person1.name = 'Jacob'
) AS Q
WHERE Q.LastNode = 'Alice';

-- Find people 1-3 hops away from a given person
SELECT Person1.name AS PersonName, 
       STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM
    Person AS Person1,
    friendOf FOR PATH AS fo,
    Person FOR PATH  AS Person2
WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,3}))
AND Person1.name = 'Jacob';

-- Find people exactly 2 hops away from a given person
SELECT PersonName,
       Friends
FROM (
    SELECT Person1.name AS PersonName, 
           STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
           COUNT(Person2.name) WITHIN GROUP (GRAPH PATH) AS levels
    FROM
        Person AS Person1,
        friendOf FOR PATH AS fo,
        Person FOR PATH  AS Person2
    WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,3}))
    AND Person1.name = 'Jacob'
) Q
WHERE Q.levels = 2;