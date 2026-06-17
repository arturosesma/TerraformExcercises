variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where instances are launched"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs — web goes in [0], app goes in [1]"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
}

variable "key_pair_name" {
  description = "Existing key pair name for SSH. Empty string disables SSH ingress."
  type        = string
  default     = ""
}
