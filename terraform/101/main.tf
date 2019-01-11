module "my-module" {
  source = "./my-module"

  ami                = "ami-db24d8b6"
  subnet_id          = "subnet-c02e6198"
  vpc_security_group = ["sg-b1fe76ca"]
  identity           = "..."
  instance_type      = "t2.micro"
}

output "public_ip" {
  value = "${module.my-module.public_ip}"
}
