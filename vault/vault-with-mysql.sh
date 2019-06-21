#!/bin/bash
: '
Install and set up Hasicorp vault with MySql.
This script uses letsencrypt to generate certificate.
Try not to use this script on local machine due to possible certificate issue.
Author: Nitish Jadia | jadia.dev
Date: 2019-06-21
Version: v0.1 ; There maybe numerous bug. Please open an issue or a pull request.
'
# Author: github.com/th3karkota

if [[ "$#" -eq 0 ]]; then
    echo "Give your website name as argument and password."
    echo "EX: ./vaultInstall jadia.dev Password@123"
    exit 1
fi

apt-get update
apt-get install -y wget curl unzip

# Download vault and configure basic vault
wget -O vault.zip "https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip"
unzip -u vault.zip
sudo chown root:root vault
mv -f vault /usr/local/bin/
vault -autocomplete-install
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
sudo useradd --system --home /etc/vault.d --shell /bin/false vault
# Create vault service
sudo touch /etc/systemd/system/vault.service
echo '''
    [Unit]
    Description="HashiCorp Vault - A tool for managing secrets"
    Documentation=https://www.vaultproject.io/docs/
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=/etc/vault.d/vault.hcl

    [Service]
    User=vault
    Group=vault
    ProtectSystem=full
    ProtectHome=read-only
    PrivateTmp=yes
    PrivateDevices=yes
    SecureBits=keep-caps
    AmbientCapabilities=CAP_IPC_LOCK
    Capabilities=CAP_IPC_LOCK+ep
    CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
    NoNewPrivileges=yes
    ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
    ExecReload=/bin/kill --signal HUP $MAINPID
    KillMode=process
    KillSignal=SIGINT
    Restart=on-failure
    RestartSec=5
    TimeoutStopSec=30
    StartLimitIntervalSec=60
    StartLimitBurst=3
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target
''' > /etc/systemd/system/vault.service
mkdir -p /home/vault

# Setting permissions to vault.hcl file
sudo mkdir --parents /etc/vault.d
sudo touch /etc/vault.d/vault.hcl
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl


# Install docker
bash -c "$(curl -fsSL https://get.docker.com/)"
# Create certificate
mkdir $PWD/certbotFiles/ && \
docker run -it --rm --name certbot \
-v "$PWD/certbotFiles/etc/letsencrypt:/etc/letsencrypt" \
-v "$PWD/certbotFiles/var/lib:/var/lib/letsencrypt" \
-p 80:80 \
certbot/certbot certonly \
--standalone \
--server https://acme-v02.api.letsencrypt.org/directory \
--agree-tos \
--email sys@rtcamp.com \
--manual-public-ip-logging-ok \
--no-eff-email \
--renew-by-default \
--text -d $1

mkdir -p /home/vault/
cp /etc/letsencrypt/archive/$1/* /home/vault/
rm -rf vault.zip
# setting permissions to certificate and keys
sudo chown --recursive vault:vault /home/vault
# clean-up
rm -rf $PWD/certbotFiles

# configure vault.hcl
echo '''listener "tcp" {
address       = "0.0.0.0:8200"
tls_cert_file = "/home/vault/fullchain.pem"
tls_key_file  = "/home/vault/privkey.pem"
}
api_addr = "localhost:8200"
storage "mysql" {
username = "root"
password = "goodwork"
}
ui = true
''' > /etc/vault.d/vault.hcl
sed -i -r -e "s/localhost/$1/" /etc/vault.d/vault.hcl

# TODO CHANGE DEFAULT MYSQL PASSWORD
# change default mysql password
# if [[ "$#" -eq 2 ]]; then
#     sed -i -r -e "s/goodwork/$2/" /etc/vault.d/vault.hcl
# fi

## Install and configure MySQL

sudo apt install mysql-server -y
systemctl start mysql
# Enable remote connection
sed -i -r -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'goodwork'; flush privileges;"

mysql -u root --password="goodwork" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'goodwork';" --connect-expired-password
systemctl restart mysql
systemctl stop vault && systemctl start vault
echo
echo "Done"
