# retrieves a generic secret from vault's kv store (invokes secret function from consul templating language, even though this looks like Go templating)
{{ with secret "secret/my-secret" }}
{{ .data.data.foo }}
{{ end }}
