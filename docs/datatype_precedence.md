# Data type precedence

The data types have precedence order for SQL Server and the lower precedence data type is converted to the higher precedence data type.

    user-defined data types (highest)
    sql_variant
    xml
    datetimeoffset
    datetime2
    datetime
    smalldatetime
    date
    time
    float
    real
    decimal
    money
    smallmoney
    bigint
    int
    smallint
    tinyint
    bit
    ntext
    text
    image
    timestamp
    uniqueidentifier
    nvarchar (including nvarchar(max) )
    nchar
    varchar (including varchar(max) )
    char
    varbinary (including varbinary(max) )
    binary (lowest) 

# Data type conversion

    to->     DATETIME  FLOAT     DECIMAL   INTEGER   BIT       NVARCHAR  VARCHAR
    from
    DATETIME    -         X         X         X         X         +         +
    FLOAT       +         -         +         +         +         +         +
    DECIMAL     +         +         -         +         +         +         +
    INTEGER     +         +         +         -         +         +         +
    BIT         +         +         +         +         -         +         +
    NVARCHAR    +         +         +         +         +         -         +
    VARCHAR     +         +         +         +         +         +         -

All possible data conversions cannot be made by SQL Server f.e.

`SELECT intColumn FROM table WHERE intColumn = N'A'`

Will give error:

<span style="color:red">Conversion failed when converting the nvarchar value 'A' to data type int. </span>

