# increase log verbosity
log_level = "DEBUG"

# setup data dir
data_dir = "/tmp/server1"

# enable the server
server {
  enabled = true

  # self-elect; should be 3 or 5 for production
  bootstrap_expect = 1
}
