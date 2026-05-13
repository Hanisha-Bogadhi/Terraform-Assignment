provider "aws" {
  region = var.region
}

# ---------------- VPC ----------------

resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public1" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-south-2a"

  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-south-2b"

  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a1" {

  subnet_id = aws_subnet.public1.id

  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "a2" {

  subnet_id = aws_subnet.public2.id

  route_table_id = aws_route_table.public_rt.id
}

# ---------------- SECURITY GROUP ----------------

resource "aws_security_group" "ecs_sg" {

  vpc_id = aws_vpc.main.id

  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    from_port = 3000

    to_port = 3000

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    from_port = 5000

    to_port = 5000

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- ECR ----------------

resource "aws_ecr_repository" "backend_repo" {

  name = var.backend_image
}

resource "aws_ecr_repository" "frontend_repo" {

  name = var.frontend_image
}

# ---------------- ECS ----------------

resource "aws_ecs_cluster" "cluster" {

  name = "hanisha-cluster"
}

# ---------------- ALB ----------------

resource "aws_lb" "alb" {

  name = "hanisha-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [aws_security_group.ecs_sg.id]

  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]
}

resource "aws_lb_target_group" "frontend_tg" {

  name = "frontend-tg"

  port = 3000

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {

    path = "/"
  }
}

resource "aws_lb_listener" "listener" {

  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}