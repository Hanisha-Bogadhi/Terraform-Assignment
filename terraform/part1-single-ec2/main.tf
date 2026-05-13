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

              apt update -y

              apt install -y python3-pip nodejs npm git

              cd /home/ubuntu

              git clone ${var.repo_url}

              cd terraform-flask-express-assignment/backend

              pip3 install -r requirements.txt

              nohup python3 app.py &

              cd ../frontend

              npm install

              nohup node app.js &

              EOF

  tags = {
    Name = "Single-EC2"
  }
}