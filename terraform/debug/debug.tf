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

variable "count" {
  default = 8
}

variable "list_a" {
  default = ["app01", "app02"]
}

output "list_join" {
  value = "${join(".domain,", var.list_a)}"
}
