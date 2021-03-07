# SQL Server Services

## Alter the current state of the service

| Action | Command |
|---|---|
| Start | `sudo systemctl start mssql-server` |
| Stop | `sudo systemctl stop mssql-server` |
| Restart | `sudo systemctl restart mssql-server` |

## Use default configuration on server reboot

| Action | Command |
|---|---|
| Enable | `sudo systemctl enable mssql-server` |
| Disable | `sudo systemctl disable mssql-server` |

## Current status of the service

| Action | Command |
|---|---|
| Status | `sudo systemctl status mssql-server` |

## Remarks

### If service refuses to stop gracefully it can be killed by using:

`sudo systemctl kill mssql-server`

### Also you can use service instead of systemctl

`service <action> <service-name>`