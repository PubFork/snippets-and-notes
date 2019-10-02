# for testing functions etc. resolved assigned values
variable "test" {
  default = "'weird#password"
}

output "test_output" {
  value = "${replace(var.test, "/(`|#|'|\")/", "`$1")}"
}

output "other_output" {
  value = "${var.test}andotherstuff"
}
