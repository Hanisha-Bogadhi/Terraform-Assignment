provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# ---------------- VPC ----------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# ---------------- SUBNETS ----------------

resource "aws_subnet" "public1" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.10.0/24"

  availability_zone = "ap-south-2a"

  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.20.0/24"

  availability_zone = "ap-south-2b"

  map_public_ip_on_launch = true
}

# ---------------- INTERNET GATEWAY ----------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# ---------------- ROUTE TABLE ----------------

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

  name = "hanisha-ecs-sg"

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

# ---------------- ECS CLUSTER ----------------

resource "aws_ecs_cluster" "cluster" {
  name = "hanisha-cluster"
}

# ---------------- IAM ROLE ----------------

resource "aws_iam_role" "ecs_task_execution_role" {

  name = "hanisha-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"

      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {

  role = aws_iam_role.ecs_task_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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

# ---------------- FRONTEND TARGET GROUP ----------------

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

# ---------------- BACKEND TARGET GROUP ----------------

resource "aws_lb_target_group" "backend_tg" {

  name = "backend-tg"

  port = 5000

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

# ---------------- FRONTEND LISTENER ----------------

resource "aws_lb_listener" "frontend_listener" {

  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# ---------------- BACKEND LISTENER ----------------

resource "aws_lb_listener" "backend_listener" {

  load_balancer_arn = aws_lb.alb.arn

  port = 5000

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# ---------------- BACKEND TASK ----------------

resource "aws_ecs_task_definition" "backend_task" {

  family = "backend-task"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = "256"

  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "backend"

      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-south-2.amazonaws.com/${var.backend_image}:latest"

      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

# ---------------- FRONTEND TASK ----------------

resource "aws_ecs_task_definition" "frontend_task" {

  family = "frontend-task"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = "256"

  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"

      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-south-2.amazonaws.com/${var.frontend_image}:latest"

      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

# ---------------- BACKEND ECS SERVICE ----------------

resource "aws_ecs_service" "backend_service" {

  name = "backend-service"

  cluster = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.backend_task.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {

    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id
    ]

    security_groups = [aws_security_group.ecs_sg.id]

    assign_public_ip = true
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.backend_tg.arn

    container_name = "backend"

    container_port = 5000
  }

  depends_on = [aws_lb_listener.backend_listener]
}

# ---------------- FRONTEND ECS SERVICE ----------------

resource "aws_ecs_service" "frontend_service" {

  name = "frontend-service"

  cluster = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.frontend_task.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {

    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id
    ]

    security_groups = [aws_security_group.ecs_sg.id]

    assign_public_ip = true
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.frontend_tg.arn

    container_name = "frontend"

    container_port = 3000
  }

  depends_on = [aws_lb_listener.frontend_listener]
}