CREATE TABLE temp
    (ID int, name varchar(50));

INSERT INTO temp
    ([ID], [name])
VALUES
    (1, 'Value 1'),
    (2, 'Value 2');

SELECT  'first' as [param/@name],
        ID as [param],
        (SELECT 'second' as [param/@name], 
                name as [param] 
        FROM temp t1 WHERE t1.ID = t.ID 
        FOR XML PATH(''), TYPE )  
FROM temp t
FOR XML PATH('row'), root('root')

--or

SELECT  'first' as [param/onemore/@name]
        ,ID as [param/onemore]
        ,'' AS [param]
        ,'second' as [param/onemore/@name]
        ,[name] as [param/onemore] 
FROM temp t
FOR XML PATH('row'), root('root');