output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "ec2_web_instance_id" {
  description = "Web server EC2 instance ID"
  value       = module.ec2.web_instance_id
}

output "ec2_app_instance_id" {
  description = "App server EC2 instance ID"
  value       = module.ec2.app_instance_id
}

output "ec2_web_public_ip" {
  description = "Web server public IP"
  value       = module.ec2.web_instance_public_ip
}

output "ec2_app_public_ip" {
  description = "App server public IP"
  value       = module.ec2.app_instance_public_ip
}

output "rds_endpoint" {
  description = "RDS connection endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.port
}

output "s3_bucket_name" {
  description = "Name of the Arturo S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the Arturo S3 bucket"
  value       = module.s3.bucket_arn
}
