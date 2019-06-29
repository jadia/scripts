listener "tcp" {
address       = "0.0.0.0:8200"
tls_cert_file = "/home/vault/fullchain.pem"
tls_key_file  = "/home/vault/privkey.pem"
}

api_addr = "localhost:8200"

storage "mysql" {
address = "db:3306"
username = "root"
password = "goodwork"
}

ui = true