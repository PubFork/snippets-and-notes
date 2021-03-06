provider "aws" {
  version = "~> 1.5"

  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > file.txt"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}

module "consul" {
  source = "github.com/hashicorp/consul/terraform/aws"

  key_name = ""
  key_path = ""
  region   = "us-east-1"
  servers  = "3"
}
