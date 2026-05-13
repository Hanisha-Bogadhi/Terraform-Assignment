provider "aws" {
  region = var.region
}

resource "aws_security_group" "app_sg" {
  name = "single-ec2-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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

resource "aws_instance" "single_ec2" {

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
        #!/bin/bash

        sleep 30

        apt update -y

        apt install -y python3-pip python3-flask nodejs npm git

        pip3 install --break-system-packages flask-cors

        cd /home/ubuntu

        git clone ${var.repo_url} || true

        cd Terraform-Assignment/backend

        nohup python3 app.py > backend.log 2>&1 &

        sleep 10

        cd ../frontend

        npm install

        nohup node server.js > frontend.log 2>&1 &

        EOF

  tags = {
    Name = "Single-EC2"
  }
}