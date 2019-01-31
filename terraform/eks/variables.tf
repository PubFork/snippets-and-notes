variable "cluster_name" {
  type        = "string"
  default     = "test-eks"
  description = "The name of the EKS Cluster."
}

variable "vpc_name" {
  type        = "string"
  default     = "test-vpc"
  description = "The name of the VPC."
}

variable "region" {
  type        = "string"
  default     = "us-west-2"
  description = "The region for the EKS and VPC."
}

variable "asg_size" {
  type        = "string"
  default     = "3"
  description = "Auto scaling group size for worker nodes."
}

variable "asg_min_size" {
  type        = "string"
  default     = "3"
  description = "Minimum auto scaling group size for worker nodes."
}

variable "asg_max_size" {
  type        = "string"
  default     = "3"
  description = "Maximum auto scaling group size for worker nodes."
}

variable "aws_profile" {
  type        = "string"
  default     = "default"
  description = "The AWS profile to use."
}

variable "worker_instance_type" {
  type        = "string"
  default     = "m4.large"
  description = "The instance type for the worker nodes in the auto scaling group."
}
