# increase log verbosity
log_level = "DEBUG"

# setup data dir
data_dir = "/tmp/client1"

# give the agent a unique name; defaults to hostname
name = "client1"

# enable the client
client {
  enabled = true

  # For demo assume we are talking to server1. For production, this should be like "nomad.service.consul:4647" and a system like Consul used for service discovery.
  servers = ["127.0.0.1:4647"]
}

# modify our port to avoid a collision with server1
ports {
  http = 5656
}
