terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "minecraft_key_pair" {
  key_name = "minecraft-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.minecraft_key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
  file_permission = "0400"
}

provider "aws" {
  region  = "us-west-2"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "minecraft_sg" {
  name = "minecraft-sg"
  description = "Allow connections to minecraft server"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "Minecraft ingress"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                         = "ami-03f65b8614a860c29"
  instance_type               = "t2.small"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.minecraft_sg.id]
  key_name                    = aws_key_pair.minecraft_key_pair.key_name
  user_data                   = file("setup.sh")
  tags = {
    Name = "MinecraftServer"
  }
}

