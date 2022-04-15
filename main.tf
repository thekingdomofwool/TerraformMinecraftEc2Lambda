terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

resource "aws_instance" "minecraft_server" {
  ami           = "ami-06542a822d33e2e40"
  instance_type = "t2.micro"
  associate_public_ip_address = true
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
        wget https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar
        sudo chown -R minecraft:minecraft /opt/minecraft/
        sudo java -Xmx1024M -Xms1024M -jar minecraft_server.1.18.2.jar nogui
       
EOF
  tags = {
    auto-start = true 
  }
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

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["13.52.6.112/29"]
  
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.minecraft_server.public_ip
}
