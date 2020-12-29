# mssql-conf

Syntax to check information about mssql-conf tool.

`sudo /opt/mssql/bin/mssql-conf -h`

## mssql-conf list

We can configure multiple parameters using the mssql-conf tool. This option provides a list of supported configuration settings.

Syntax to list options for the mssql-conf tool.

`/opt/mssql/bin/mssql-conf list`

We can see there that it supports below operations.

*tcpport*: Change the port where SQL Server will listen for connections.

*defaultdatadir* (Default data directory): Change the directory where the new SQL Server database data files (.mdf) are created.

*defaultlogdir* (Default log directory): Changes the directory where the new SQL Server database log (.ldf) files are created.

*defaultdumpdir* (Default dump directory): Change the directory where SQL Server will deposit memory dumps and other troubleshooting files by default.

*defaultbackupdir* (Default backup directory): Change the directory where SQL Server will send the backup files by default.

## mssql-conf set

This sets a new value of a SQL Server settings i.e. TCP port, default data directory, default log directory, default backup directory, etc. For example, if we want to configure SQL Server to use port 5500 we need to execute the following statement:

`mssql-conf set tcpport 5500`

## mssql-conf unset

We can reset the original values of SQL Server setting using the unset parameter. For example, to reset the SQL Server port to default values 1433, use the below code:

`mssql-conf  unset tcpport`

## mssql-conf traceflags

We can set the traceflags that the SQL Server service will use globally. For example, if we want to run the traceflag 1204 globally, run the below code:

`sudo /opt/mssql/bin/mssql-conf traceflag 1204 on`

## mssql-conf set-sa-password

We can reset the sa password using this parameter. To reset the sa password, run the below code and restart the SQL Server services.

`sudo /opt/mssql/bin/mssql-conf set-sa-password 'newpassword'`

## mssql-conf set-collation

We can set the collation for SQL Server on Linux. Suppose we want to set the server collation to Latin1_General_CS_AS, so we need to run the below code and restart the services.

`sudo /opt/mssql/bin/mssql-conf Latin1_General_CS_AS`

## mssql-conf validate

This validates the configuration file and removes settings that are not acceptable.  Below is the code to do so:

`sudo /opt/mssql/bin/mssql-conf validate`

## mssql-conf accept-eula

This command accepts the license terms for SQL Server on Linux.

The mssql-conf tool creates a configuration file to store the user specified configuration changes.  These configurations are stored in the mssql.conf config file located at /var/opt/mssql. During SQL Server startup the customized values and parameters are read from this config file and then applied to SQL Server.