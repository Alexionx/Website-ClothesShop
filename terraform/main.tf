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
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id] # Прив'язка Security Group  

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "WebApplication"
  }
}

# посилаюсь на існуючу security group

data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["new_app_security_group"]  # Вкажіть ім'я вашої існуючої групи безпеки
  }
}

resource "aws_ssm_parameter" "ec2_public_ip" { 
  name  = "/my_app/ec2_public_ip" # Назва параметра
  type  = "String"
  value = aws_instance.app_server.public_ip
}


