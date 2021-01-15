USE DEMO;

SELECT @@VERSION;

EXEC sp_execute_external_script   
@language =N'R', 
@script=N' 
OutputDataSet <- InputDataSet', 
@input_data_1 =N'SELECT ''world'' AS hello' 
WITH RESULT SETS (([hello] nvarchar(max) not null)); 
--*hello
--*world

EXECUTE sp_execute_external_script @language = N'R',
    @script = N'
a <- 1
b <- 2
c <- a/b
d <- a*b
print(c(c, d))
';
--* STDOUT message(s) from external script:
--* [1] 0.5 2.0 