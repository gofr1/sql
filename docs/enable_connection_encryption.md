# Encrypting Connections to SQL Server on Linux

## Create a certificate/keys

Use fully qualified domain name (FQDN) or machine name (hostname). In `chown` use group and user that runs SQL Server. In this example self-signed certificate is used.

    openssl req -x509 -nodes -newkey rsa:2048 -subj '/CN=hostname' -keyout hostname.key -out hostname.pem -days 365
    sudo chown mssql:mssql hostname.pem hostname.key
    sudo chmod 600 hostname.pem hostname.key
    sudo mv hostname.pem /etc/ssl/certs/
    sudo mv hostname.key /etc/ssl/private/

## Configure SQL Server

    systemctl stop mssql-server 
    cat /var/opt/mssql/mssql.conf 
    sudo /opt/mssql/bin/mssql-conf set network.tlscert /etc/ssl/certs/hostname.pem 
    sudo /opt/mssql/bin/mssql-conf set network.tlskey /etc/ssl/private/hostname.key 
    sudo /opt/mssql/bin/mssql-conf set network.tlsprotocols 1.2 
    sudo /opt/mssql/bin/mssql-conf set network.forceencryption 0 

Or `sudo /opt/mssql/bin/mssql-conf set network.forceencryption 1` to force encryption.

## Register the certificate on your client machine

If you are using CA signed certificate, you have to copy the Certificate Authority (CA) certificate instead of the user certificate to the client machine.

If you are using the self-signed certificate, just copy the `.pem` file to the following folders respective to distribution and execute the commands to enable them. Copy cert to `/usr/share/ca-certificates/`, rename its extension to `.crt`, and use `sudo dpkg-reconfigure ca-certificates` to enable it as system CA certificate.