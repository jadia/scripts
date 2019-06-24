FROM ubuntu:bionic
LABEL description="Install and set up Hasicorp vault with MySql. \
    This script uses letsencrypt to generate certificate. \
    "

LABEL version = "1.0"
LABEL maintainer = "jadia.dev"

EXPOSE 8200 3306 8201

RUN apt-get update && \
    apt-get install wget unzip -y

RUN wget -O vault.zip "https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip" && \
    unzip -u vault.zip

RUN chown root:root vault && \
    mv -f vault /usr/local/bin/

RUN apt-get install libcap2-bin -y && \
    setcap cap_ipc_lock=+ep /usr/local/bin/vault && \
    useradd --system --home /etc/vault.d vault

RUN mkdir -p /home/vault && \
    mkdir --parents /etc/vault.d && \
    touch /etc/vault.d/vault.hcl && \
    chown --recursive vault:vault /etc/vault.d

RUN chmod 640 /etc/vault.d/vault.hcl

ENTRYPOINT /usr/local/bin/vault server -config=/etc/vault.d/vault.hcl

