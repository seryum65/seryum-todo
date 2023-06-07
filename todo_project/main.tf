terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  # backend "s3" {
  #   bucket = "jenkins-project-backend-seryum"
  #   key = "backend/tf-backend-jenkins.tfstate"
  #   region = "us-east-1"
    
  # }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "aws_access" {
  name = "awsrole-${var.user}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/IAMFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]

}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "todo-project-profile-${var.user}"
  role = aws_iam_role.aws_access.name
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
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
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