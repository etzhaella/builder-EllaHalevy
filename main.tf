# Data source to get the default VPC if not specified
data "aws_vpc" "selected" {
  count = var.vpc_id == "" ? 1 : 0
  default = true
}

data "aws_vpc" "specified" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

locals {
  vpc_id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.selected[0].id
}

# Data source to find public subnet
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

data "aws_subnet" "public" {
  count = var.subnet_id == "" ? 1 : 0
  id    = data.aws_subnets.public.ids[0]
}

locals {
  subnet_id = var.subnet_id != "" ? var.subnet_id : data.aws_subnet.public[0].id
}

# Data source to find the AMI (Amazon Linux 2023) if not specified
data "aws_ami" "amazon_linux" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux[0].id
}

# Data source to find the key pair
data "aws_key_pair" "existing" {
  count    = var.key_pair_name != "" ? 1 : 0
  key_name = var.key_pair_name
}

# Security Group
resource "aws_security_group" "builder_sg" {
  name        = "builder-sg"
  description = "Security group for builder EC2 instance"
  vpc_id      = local.vpc_id

  # SSH access - restricted to your IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # HTTP access
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "builder-security-group"
  })
}

# EC2 Instance
resource "aws_instance" "builder" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [aws_security_group.builder_sg.id]

  # Enable public IP
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "builder-instance"
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }
}

