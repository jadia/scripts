# Hashicorp Vault with MySQL 

## Install directly on machine

### Installation

Pass site name as argument.

```bash
chmod +x vault-with-mysql.sh
sudo ./vault-with-mysql.sh EXAMPLE.COM
```

The script will install and configure vault and MySQL. It also creates new certificates using letsencrypt.

### Access vault

`https://example.com:8200`

P.S. :- https is must.


## Install via Docker

MySQL service needs to start before vault start. In newer docker-compose api versions `conditions` under `depends_on` has been removed, so temporarily we have to depend on below command.


```bash
cd vault
docker-compose up -d db && sleep 10 && docker-compose up -d vault
```

