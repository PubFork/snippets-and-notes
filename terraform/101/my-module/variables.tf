variable "access_key" {
  type = "string"

  description = "AWS access key"
}

variable "secret_key" {
  type = "string"

  description = "AWS secret key"
}

variable "identity" {
  type = "string"

  description = "User identity"
}

variable "region" {
  type = "string"

  description = "AWS region"

  default = "us-east-1"
}

variable "images" {
  type = "map"

  description = "AMIs for each region"

  default = {
    us-east-1 = "image-1234"
    us-west-2 = "image-5678"
  }
}

variable "zones" {
  type = "list"

  description = "List of AWS zones"

  default = ["us-east-1a", "us-east-1b"]
}

variable "label" {
  type = "string"

  description = "resource label"

  default = "training"
}

variable "num_webs" {
  type = "string"

  description = "Number of web instances"

  default = "2"
}

variable "ami" {
  type = "string"

  description = "AMI id"
}

variable "subnet_id" {
  type = "string"

  description = "Subnet ID for the instance"
}

variable "vpc_security_group" {
  type = "list"

  description = "VPC Security group list"
}

variable "instance_type" {
  type = "string"

  description = "AWS EC2 instance type"
}
