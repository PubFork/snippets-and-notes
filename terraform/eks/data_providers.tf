terraform {
  required_version = "~> 0.11"
}

provider "aws" {
  version = "~> 1.57"
  region  = "${var.region}"
  profile = "${var.aws_profile}"
}

provider "kubernetes" {
  config_path    = "kubeconfig"
  config_context = "aws"
}

data "aws_availability_zones" "available" {}
