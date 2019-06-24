#!/bin/bash
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
--email someRandomEmail@yopmail.com \
--manual-public-ip-logging-ok \
--no-eff-email \
--renew-by-default \
--text -d $1

mkdir $PWD/cert
cp $PWD/certbotFiles/etc/letsencrypt/archive/$1/fullchain*.pem ./cert/fullchain.pem
cp $PWD/certbotFiles/etc/letsencrypt/archive/$1/privkey*.pem ./cert/privkey.pem
chmod -r 777 $PWD/cert
