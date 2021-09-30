terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    encrypt = true
    bucket = "my-terra-bucket-99"
    key    = "terraform-bk/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Create a simple Ec2 inatnces as a Web Server Nginx and Security Groups to permit tranfic from all (Ports: 80/22)
resource "aws_security_group" "web_security_g" {
  name = "web-security-grpup"

  ingress {
     from_port = 22
     to_port = 22
     protocol = "tcp" 
     cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
     from_port = 80
     to_port = 80
     protocol = "tcp" 
     cidr_blocks = ["0.0.0.0/0"]
  } 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "Web_Server_SG"
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name = "poc-ec2keypair"
  security_groups = ["${aws_security_group.web_security_g.name}"]
  user_data = "${file("install_nginx.sh")}"

  tags = {
    Name = "Web_Server"
    EEnvironment = "${var.env_tag}"
  }
}