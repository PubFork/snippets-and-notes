storage "consul" {
  address        = "127.0.0.1:8500"
  path           = "vault"
  scheme         = "https"
  tls_ca_file    = "/etc/pem/vault.ca"
  tls_cert_files = "/etc/pem/vault.cert"
  tls_key_file   = "/etc/pem/vault.key"
}

listener "tcp" {
  address       = "127.0.0.1:8200"
  tls_disable   = 1
  tls_cert_file = "/etc/certs/vault.crt"
  tls_key_file  = "/etc/certs/vault.key"
}

listener "tcp" {
  address = "10.0.0.5:8200"

  telemtry {
    unauthenticated_metrics_access = true
  }
}

telemetry {
  statsite_address = "127.0.0.1:8125"
  disable_hostname = true
}

seal "awskms" {
  region     = "us-east-1"
  access_key = "hash"
  secret_key = "hash"
  kms_key_id = "hash"
  endpoint   = "https://vpce-hash.kms.us-east-1.vpce.amazonaws.com"
}

ui = true
