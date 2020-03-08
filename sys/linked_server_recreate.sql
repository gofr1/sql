;WITH cte AS (
SELECT  a.*,
        c.name as locallogin,
        b.remote_name,
        b.uses_self_credential, 
        b.local_principal_id
FROM sys.Servers a
LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
), unp AS (

SELECT  server_id,
        name,
        product,
        [provider],
        [data_source],
        CASE WHEN remote_name IS NULL THEN 'NULL' ELSE 'N''' + remote_name +'''' END as rmtuser,
        CASE WHEN uses_self_credential = 0 THEN 'false' ELSE 'true' END as useself,
        CASE WHEN local_principal_id = 0 THEN 'NULL' ELSE 'N''' + locallogin +'''' END as locallogin,
        Prop as PropertyName,
        CASE WHEN Props = 0 THEN 'false' ELSE 'true' END as PropertyValue
FROM (
    SELECT  server_id,
            name,
            product,
            [provider],
            [data_source],
            locallogin,
            remote_name,
            uses_self_credential,
            local_principal_id,
            CAST([is_collation_compatible] as int) as [collation compatible],
            CAST([is_data_access_enabled] as int) as [data access],
            CAST([is_distributor] as int) as [dist],
            CAST([is_publisher] as int) as [pub],
            CAST([is_remote_login_enabled] as int) as [rpc],
            CAST([is_rpc_out_enabled] as int) as [rpc out],
            CAST([is_subscriber] as int) as [sub],
            CAST([connect_timeout] as int) as [connect timeout],
            CAST([collation_name] as int) as [collation name],
            CAST([lazy_schema_validation] as int) as [lazy schema validation],
            CAST([query_timeout] as int) as [query timeout],
            CAST([uses_remote_collation] as int) as [use remote collation],
            CAST([is_remote_proc_transaction_promotion_enabled] as int) as [remote proc transaction promotion]
    FROM cte
) as p
UNPIVOT (
    Props FOR Prop IN (
            [collation compatible],
            [data access],
            [dist],
            [pub],
            [rpc],
            [rpc out],
            [sub],
            [connect timeout],
            [collation name],
            [lazy schema validation],
            [query timeout],
            [use remote collation],
            [remote proc transaction promotion]
    )
) as unpvt
WHERE name = 'Your LS name here'
)

SELECT TOP 1 'USE [master] GO' + CHAR(10) +
'EXEC master.dbo.sp_addlinkedserver @server = N''' + name + ''', @srvproduct=N''' + [provider] + '''' + CHAR(10) +
'EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N''' + name + ''',@useself=N'''+useself+''',@locallogin='+locallogin+',@rmtuser=N''' + rmtuser +''',@rmtpassword=''########'' GO' + CHAR(10)
FROM unp
UNION ALL
SELECT 'EXEC master.dbo.sp_serveroption @server=N'''+name+''', @optname=N'''+PropertyName + ''', @optvalue=N''' + PropertyValue +''' GO' + CHAR(10)
FROM unp
FOR XML PATH('')