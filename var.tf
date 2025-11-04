variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Name of the AWS Key Pair"
  type        = string
  default     = "builder-key"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created (leave empty to use default VPC)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance (leave empty to auto-detect public subnet)"
  type        = string
  default     = ""
}

variable "my_ip" {
  description = "Your IP address for SSH access (CIDR format)"
  type        = string
  default     = "89.139.218.142/32"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Name = "builder-instance"
    Project = "builder-EllaHalevy"
  }
}


