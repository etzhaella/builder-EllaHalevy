output "public_key_name" {
  value       = var.key_pair_name
  description = "Name of the AWS Key Pair used for the instance"
}

output "instance_id" {
  value       = aws_instance.builder.id
  description = "ID of the EC2 instance"
}

output "instance_public_ip" {
  value       = aws_instance.builder.public_ip
  description = "Public IP address of the EC2 instance"
}

output "instance_public_dns" {
  value       = aws_instance.builder.public_dns
  description = "Public DNS name of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.builder_sg.id
  description = "ID of the security group"
}

output "subnet_id" {
  value       = local.subnet_id
  description = "ID of the public subnet where the instance is deployed"
}

output "vpc_id" {
  value       = local.vpc_id
  description = "ID of the VPC where resources are deployed"
}
