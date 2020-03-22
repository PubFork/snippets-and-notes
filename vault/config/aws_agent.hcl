# authenticates, retrieves a token once, writes it to defined sink, and then exits because of below line
exit_after_auth = true
pid_file = "./pidfile"

auto_auth {
  method "aws" {
    mount_path = "auth/aws"
    config = {
      type = "iam"
      role = "dev-role-iam"
    }
  }

  sink "file" {
    # response-wrapping
    wrap_ttl = "5m"
    config = {
      path = "/home/ubuntu/vault-token-via-agent"
    }
  }
}

# agent caching
cache {
  use_auto_auth_token = true
}

listener "tcp" {
  address                = "127.0.0.1:8200"
  tls_disable            = true
  # server side request forgery protection
  require_request_header = true
}

vault {
  address = "http://10.0.101.53:8200"
}
