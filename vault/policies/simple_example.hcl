# grant read capability to the path secret/foo; requires the user to create "secret/foo" with a parameter named "bar" and "baz"
path "secret/foo" {
  capabilities        = ["read"]
  required_parameters = ["bar", "baz"]
}

# this allows the user to create "secret/foo" with a parameter named "bar"; the parameter "bar" can only contain the values "zip" or "zap-<anything>", but any other parameters may be created with any value
path "secret/foo" {
  capabilities = ["create"]
  allowed_parameters = {
    "bar" = ["zip", "zap-*"]
    "*" = []
  }
}

# parameter may not be named baz; "foo" cannot contain values zip or zap
path "secret/foo" {
  capabilities = ["create"]
  denied_parameters = {
    "baz" = []
    "foo" = ["zip", "zap"]
  }
}

# allow and denied function based on normal set theory (not allowed is denied, and not denied is allowed)

# policy paths targeting list capability should end with a trailing slash because listing always operates on a prefix
path "secret/foo/" {
  capabilities = ["list"]
}

# permit reading everything under "secret/bar"; an attached token could read "secret/bar/zip", "secret/bar/zip/zap", but not "secret/bars/zip"
path "secret/bar/*" {
  capabilities = ["read"]
}

# permit reading everything prefixed with "zip-"; an attached token could read "secret/zip-zap" or "secret/zip-zap/zong", but not "secret/zip/zap
path "secret/zip-*" {
  capabilities = ["read"]
}

# permit reading the "teamb" path under any top-level path under secret/
path "secret/+/teamb" {
  capabilities = ["read"]
}

# permit reading secret/foo/bar/teamb, secret/bar/foo/teamb, etc.
path "secret/+/+/teamb" {
  capabilities = ["read"]
}

# this section grants all access on "secret/*".
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# this line explicitly denies secret/super-secret; this takes precedence
path "secret/super-secret" {
  capabilities = ["deny"]
}

# here the key "secret/restricted" can only contain "foo" (any value) and "bar" (one of "zip" or "zap")
path "secret/restricted" {
  capabilities = ["create"]

  allowed_parameters = {
    "foo" = []
    "bar" = ["zip", "zap"]
  }
}
