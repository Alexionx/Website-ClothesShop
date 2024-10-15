terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-00f251754ac5da7f0"
  instance_type = "t2.micro"
  key_name      = "devops-practice-test-key"
  vpc_security_group_ids = [aws_security_group.app_sg.id] # Прив'язка Security Group  

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "WebApplication"
  }
}

output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

# налаштування security group
resource "aws_security_group" "app_sg" {
  name        = "new_app_security_group"
  description = "Security group for EC2 app"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Дозволяє SSH доступ
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Дозволяє HTTP доступ
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Дозволяє HTTPS доступ
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Дозволяє доступ на порт 3000
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Дозволяє весь вихідний трафік
    cidr_blocks = ["0.0.0.0/0"]
  }
}

