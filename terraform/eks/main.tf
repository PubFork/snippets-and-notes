locals {
  worker_groups = "${list(
                  map("instance_type", "${var.worker_instance_type}",
                      "asg_desired_capacity", "${var.asg_size}",
                      "asg_max_size", "${var.asg_max_size}",
                      "asg_min_size", "${var.asg_min_size}",
                      "name", "worker_group_a",
                  )
  )}"

  #default = {
  #  name                 = "count.index" # Name of the worker group. Literal count.index will never be used but if name is not set, the count.index interpolation will be used.
  #  ami_id               = ""            # AMI ID for the eks workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI.
  #  asg_desired_capacity = "1"           # Desired worker capacity in the autoscaling group.
  #  asg_max_size         = "3"           # Maximum worker capacity in the autoscaling group.
  #  asg_min_size         = "1"           # Minimum worker capacity in the autoscaling group.
  #  instance_type        = "m4.large"    # Size of the workers instances.
  #  key_name             = ""            # The key name that should be used for the instances in the autoscaling group
  #  additional_userdata  = ""            # userdata to append to the default userdata.
  #  ebs_optimized        = true          # sets whether to use ebs optimization on supported types.
  #  public_ip            = false         # Associate a public ip address with a worker
  #}

  tags = "${map("Environment", "test",
                "Workspace", "${terraform.workspace}"
  )}"
}

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "1.53.0"
  name                   = "${var.vpc_name}"
  cidr                   = "10.0.0.0/16"
  azs                    = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets         = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  tags                   = "${merge(local.tags, map("kubernetes.io/cluster/${var.cluster_name}", "shared"))}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.1.0"

  #config_output_path          = "~/.kube"
  cluster_name    = "${var.cluster_name}"
  cluster_version = "1.10"

  #subnets                     = "${concat(module.vpc.private_subnets, module.vpc.public_subnets)}"
  kubeconfig_aws_authenticator_env_variables = {
    AWS_PROFILE = "${var.aws_profile}"
  }

  subnets                     = "${module.vpc.private_subnets}"
  tags                        = "${local.tags}"
  vpc_id                      = "${module.vpc.vpc_id}"
  worker_groups               = "${local.worker_groups}"
  worker_sg_ingress_from_port = "1025"
}
