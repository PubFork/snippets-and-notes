# for testing functions etc. resolved assigned values
variable "test" {
  default = "super$ecret*variable"
}

output "test_output" {
  value = "${var.test}"
}
