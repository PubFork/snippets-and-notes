# transition from local to remote state
terraform {
  backend "consul" {
    address = "demo.consul.io"
    path    = "tfdocs"
    lock    = false
  }
}
