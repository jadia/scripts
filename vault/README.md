# Hashicorp Vault with MySQL 

## 1. Install directly on machine

### Installation

Pass site name as argument.

```bash
chmod +x vault-with-mysql.sh
sudo ./vault-with-mysql.sh EXAMPLE.COM
```

The script will install and configure vault and MySQL. It also creates new certificates using letsencrypt.

### Access vault

`https://example.com:8200`

**P.S.:-** https is must. Default database password : `goodwork`


## 2. Install via Docker

MySQL service needs to start before vault start. In newer docker-compose api versions `conditions` under `depends_on` has been removed, so temporarily we have to depend on below command.


```bash
cd vault
# Generate certificates
chmod +x generateCert.sh && ./generateCert.sh EXAMPLE.COM
# Start vault
docker-compose up -d db && sleep 10 && docker-compose up -d vault
```
To stop vault:
```bash
docker-comopose down
```
**P.S.:**- DB password can be changed by editing `docker-compose` file.