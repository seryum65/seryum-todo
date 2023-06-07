terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "jenkins-project-backend-seryum"
    key = "backend/tf-backend-jenkins.tfstate"
    region = "us-east-1"
    
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "tags" {
  default = ["CI-CD"]
}

variable "user" {
  default = "yusuf"
}

resource "aws_instance" "managed_nodes" {
  ami = "ami-016eb5d644c333ccb"
  count = 1
  instance_type = "t3a.medium"
  key_name = "seryum"
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  tags = {
    Name = "todo_${element(var.tags, count.index )}"
    stack = "todo_project"
    environment = "development"
  }
    user_data = <<-EOF
              #! /bin/bash
              dnf update -y
              EOF
}

resource "aws_security_group" "tf-sec-gr" {
  name = "todo2-sec-gr"
  tags = {
    Name = "todo2-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5050
    protocol    = "tcp"
    to_port     = 5050
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    protocol    = "tcp"
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8081
    protocol    = "tcp"
    to_port     = 8081
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "node_public_ip" {
  value = aws_instance.managed_nodes[0].public_ip

}

output "node_private_ip" {
  value = aws_instance.managed_nodes[0].private_ip

}