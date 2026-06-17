variable "aws_region" {
  description = "AWS region where all resources are deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
  default     = "arturo-project"
}

variable "environment" {
  description = "Deployment environment — drives naming and minor config differences"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

# ── Networking ────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ, used by RDS)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Availability zones matching the subnet lists above"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ── EC2 ───────────────────────────────────────────────────────────────────────

variable "ec2_instance_type" {
  description = "EC2 instance type for both web and app instances"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2023 in us-east-1)"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "key_pair_name" {
  description = "Existing EC2 Key Pair name for SSH access. Leave empty to skip SSH ingress rule."
  type        = string
  default     = ""
}

# ── RDS ───────────────────────────────────────────────────────────────────────

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_engine" {
  description = "Database engine (mysql | postgres)"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "rds_db_name" {
  description = "Name of the initial database created on the instance"
  type        = string
  default     = "arturo_db"
}

variable "rds_username" {
  description = "Master username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "Master password for the RDS instance. Use AWS Secrets Manager in production."
  type        = string
  sensitive   = true
}

# ── S3 ────────────────────────────────────────────────────────────────────────

variable "s3_bucket_name" {
  description = "Name of the Arturo S3 bucket. Must be globally unique across all AWS accounts."
  type        = string

  validation {
    condition     = length(var.s3_bucket_name) >= 3 && length(var.s3_bucket_name) <= 63
    error_message = "S3 bucket name must be between 3 and 63 characters."
  }
}
