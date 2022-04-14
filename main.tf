# Terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}
provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "minecraft_server" {
  ami           = "ami-06542a822d33e2e40"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.minecraft_server-sg.id]
  user_data = <<EOF
        #! /bin/bash
        sudo rpm --import https://yum.corretto.aws/corretto.key
        sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
        sudo yum install -y java-17-amazon-corretto-devel.x86_64
        sudo adduser minecraft
        sudo su
        mkdir /opt/minecraft/
        mkdir /opt/minecraft/server/
        cd /opt/minecraft/server
        wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar
        sudo chown -R minecraft:minecraft /opt/minecraft/
       
EOF
}
  
resource "aws_security_group" "minecraft_server-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "TLS from VPC"
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

