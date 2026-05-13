provider "aws" {
  region = var.region
}

resource "aws_security_group" "frontend_sg" {

  name = "frontend-sg"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_sg" {

  name = "backend-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "backend" {

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name

  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
#!/bin/bash

sleep 30

apt update -y

apt install -y python3-pip python3-flask git

pip3 install --break-system-packages flask-cors

cd /home/ubuntu

git clone ${var.repo_url} || true

cd Terraform-Assignment/backend

nohup python3 app.py > backend.log 2>&1 &

EOF

  tags = {
    Name = "Backend-EC2"
  }
}

resource "aws_instance" "frontend" {

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name

  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  user_data = <<-EOF
#!/bin/bash

sleep 30

apt update -y

apt install -y nodejs npm git

cd /home/ubuntu

git clone ${var.repo_url} || true

cd Terraform-Assignment/frontend

sed -i 's|http://localhost:5000|http://${aws_instance.backend.private_ip}:5000|' server.js

npm install

nohup node server.js > frontend.log 2>&1 &

EOF

  tags = {
    Name = "Frontend-EC2"
  }
}