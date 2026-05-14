# Terraform Flask & Express Deployment Assignment

## Project Overview

This assignment demonstrates deployment of a Flask backend and Express frontend application using Terraform and AWS in three different architectures.

---

# Technologies Used

- Terraform
- AWS EC2
- AWS ECS
- AWS ECR
- AWS ALB
- AWS VPC
- Docker
- Flask
- Express.js
- Node.js
- Python
- GitHub

---

# Project Structure

```bash
Terraform-Assignment/
│
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── frontend/
│   ├── server.js
│   ├── package.json
│   ├── views/
│   └── Dockerfile
│
├── part1-single-ec2/
│
├── part2-separate-ec2/
│
├── part3-ecs-ecr/
│
├── README.md
└── screenshots/
```

---

# Backend Application

- Built using Flask
- Runs on port 5000
- Receives form data from frontend

## Run Locally

```bash
pip install -r requirements.txt
python app.py
```

---

# Frontend Application

- Built using Express.js
- Runs on port 3000
- Sends requests to Flask backend

## Run Locally

```bash
npm install
node server.js
```

---

# Part 1 — Single EC2 Deployment

## Objective

Deploy both frontend and backend on one EC2 instance using Terraform.

---

# Services Used

- AWS EC2
- Security Groups
- Terraform User Data

---

# Architecture

```text
Browser
   ↓
EC2 Instance
 ├── Flask Backend (5000)
 └── Express Frontend (3000)
```

---


# Steps Performed

1. Created EC2 instance using Terraform  
2. Configured Security Group  
3. Opened ports:
   - 22
   - 3000
   - 5000
4. Installed:
   - Python
   - Node.js
   - Git
5. Cloned GitHub repository  
6. Installed dependencies  
7. Started Flask and Express applications using User Data  

---


# Terraform Commands Used

```bash
terraform init
terraform plan
terraform apply
```

---

# Verification

Frontend:

```text
http://40.192.27.109:3000
```

Backend API was verified through frontend form submission.

---

# Note

The EC2 instance was stopped and restarted after deployment. Therefore, the public IP address changed because an Elastic IP was not attached. Applications were restarted manually using the updated IP address.

---

# Screenshots Taken

- Terraform apply success
- Terraform init success
- Terraform plan output
- EC2 instance running
- Frontend working in browser
- Backend API response

---

# Part 2 — Separate EC2 Deployment

## Objective

Deploy frontend and backend on separate EC2 instances using Terraform.

---

# Services Used

- AWS EC2
- AWS VPC
- Security Groups
- Terraform

---

# Architecture

```text
Browser
   ↓
Frontend EC2 (3000)
   ↓
Backend EC2 (5000)
```

---

# Steps Performed

1. Created:
   - Frontend EC2 instance
   - Backend EC2 instance
2. Configured Security Groups  
3. Allowed communication between frontend and backend  
4. Installed required dependencies  
5. Started Flask and Express applications using User Data  

---

# Terraform Commands Used

```bash
terraform init
terraform plan
terraform apply
```

---
# Verification

Frontend:

```text
http://16.112.12.156:3000
```

Backend API was verified through frontend form submission.

# Note
The EC2 instance was stopped

---


# Screenshots Taken

- Terraform init, validate success
- Terraform plan output
- Terraform apply success
- Both EC2 instances running
- Backend security group rules
- frontend security group rules
- Working application
- Successful response

---

# Part 3 — ECS, ECR & Docker Deployment

## Objective

Deploy frontend and backend applications as Docker containers using ECS Fargate.

---

# Services Used

- AWS ECS
- AWS ECR
- AWS ALB
- AWS VPC
- Docker
- Terraform

---

# Architecture

```text
Browser
   ↓
Application Load Balancer
   ├── Frontend ECS Service
   └── Backend ECS Service
```

---

# Steps Performed

## Step 1 — Dockerized Applications

Created Dockerfiles for:
- frontend
- backend

Built Docker images:
```bash
docker build -t hanisha-backend .
docker build -t hanisha-frontend .
```

---

## Step 2 — Created ECR Repositories

Created:
- hanisha-backend
- hanisha-frontend

Pushed Docker images to ECR.

---

## Step 3 — Created Infrastructure Using Terraform
Created:
- VPC
- Subnets
- Internet Gateway
- Route Tables
- Security Groups
- ECS Cluster
- ECS Task Definitions
- ECS Services
- ALB
- Target Groups

---

## Step 4 — Deployed ECS Services

- Frontend container running on port 3000
- Backend container running on port 5000

---

## Step 5 — Configured ALB
Configured:
- Listener for frontend traffic
- Listener for backend traffic
- Target groups for ECS services

---

# Terraform Commands Used

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

# Note

The backend `/` route was added only in Part 3 to support ECS target group health checks.

---

# Screenshots Taken

- ECR repositories
- Backend docker build
- Frontend docker build
- Backend image latest
- Frontend image latest
- ECS cluster
- ECS services running
- ECS task definitions
- ALB listeners
- Backend target groups healthy
- Frontend target groups healthy
- Frontend working
- Backend working
- Terraform init success
- Terraform apply success
- Backend response sucess
- Terraform state S3 bucket

---

# Challenges Faced

- Docker authentication issues with ECR
- ECS target group health check failures
- Frontend-backend communication issues
- Terraform backend state issues

---

# Solutions Implemented

- Configured ECR authentication using AWS CLI
- Added Flask health check route for ECS
- Updated frontend backend URL using ALB DNS
- Forced ECS redeployment after image updates
- Cleaned unused AWS resources to avoid billing

---

# Cleanup

To avoid AWS charges:

```bash
terraform destroy
```

Docker cleanup:

```bash
docker system prune -a --volumes
```

---

# Learning Outcomes

- Terraform Infrastructure as Code
- AWS ECS & ECR deployment
- Docker containerization
- Application Load Balancer configuration
- ECS troubleshooting
- AWS networking basics

---