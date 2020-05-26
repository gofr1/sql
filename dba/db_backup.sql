USE master;

-- sample of backup script
-- BACKUP DATABASE [DEMO]
-- TO DISK = '/var/sqlbackup/DEMO_backup_20191116_01.bak';

DECLARE @sql VARCHAR(max) = 'USE master;',
        @backup_date datetime = CURRENT_TIMESTAMP,
        @backup_path varchar(200) = '/var/sqlbackup/'

SELECT @sql =  CONCAT(@sql, 
                      'BACKUP DATABASE ', 
                      QUOTENAME(d.name),
                      CHAR(10),
                      ' TO DISK = ''',
                      @backup_path,
                      d.name,
                      '_backup_',
                      REPLACE(
                          REPLACE(
                              CONVERT(varchar(50),@backup_date,126),
                              ':',''),
                        '-',''
                      ),
                      '.bak'';',
                      CHAR(10)
)
FROM sys.databases d 
WHERE d.database_id > 4

PRINT(@sql)
--EXEC(@sql)
