terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

###############################
# Providers for two regions
###############################
provider "aws" {
  alias  = "r1"
  region = var.region1
}

provider "aws" {
  alias  = "r2"
  region = var.region2
}

###############################
# AMI Lookups
###############################
data "aws_ami" "r1" {
  provider    = aws.r1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "r2" {
  provider    = aws.r2
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

###############################
# Default VPCs
###############################
data "aws_vpc" "r1_default" {
  provider = aws.r1
  default  = true
}

data "aws_vpc" "r2_default" {
  provider = aws.r2
  default  = true
}

###############################
# Default Subnets (Fix for missing subnet error)
###############################
data "aws_subnets" "r1_default" {
  provider = aws.r1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.r1_default.id]
  }
}

data "aws_subnets" "r2_default" {
  provider = aws.r2
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.r2_default.id]
  }
}

###############################
# Security Groups
###############################
resource "aws_security_group" "r1_sg" {
  provider    = aws.r1
  name        = "tf-sg-r1"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.r1_default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-sg-r1"
  }
}

resource "aws_security_group" "r2_sg" {
  provider    = aws.r2
  name        = "tf-sg-r2"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.r2_default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-sg-r2"
  }
}

###############################
# User-data to install Nginx
###############################
locals {
  userdata = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras enable nginx1
    yum install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from Terraform EC2 in $(hostname)</h1>" > /usr/share/nginx/html/index.html
  EOF
}

###############################
# EC2 Instances
###############################
resource "aws_instance" "r1" {
  provider               = aws.r1
  ami                    = data.aws_ami.r1.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.r1_sg.id]
  subnet_id              = data.aws_subnets.r1_default.ids[0]  # Use first available subnet
  associate_public_ip_address = true
  user_data              = local.userdata

  tags = {
    Name = "tf-ec2-${var.region1}"
  }
}

resource "aws_instance" "r2" {
  provider               = aws.r2
  ami                    = data.aws_ami.r2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.r2_sg.id]
  subnet_id              = data.aws_subnets.r2_default.ids[0]  # Use first available subnet
  user_data              = local.userdata

  tags = {
    Name = "tf-ec2-${var.region2}"
  }
}
