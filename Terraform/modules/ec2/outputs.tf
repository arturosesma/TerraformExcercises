output "web_instance_id" {
  description = "Web server instance ID"
  value       = aws_instance.web.id
}

output "app_instance_id" {
  description = "App server instance ID"
  value       = aws_instance.app.id
}

output "web_instance_public_ip" {
  description = "Web server public IP"
  value       = aws_instance.web.public_ip
}

output "app_instance_public_ip" {
  description = "App server public IP"
  value       = aws_instance.app.public_ip
}

output "security_group_id" {
  description = "EC2 security group ID — consumed by the RDS module to scope DB ingress"
  value       = aws_security_group.ec2.id
}
