###############################################################
# Terraform
# Define a versão do Terraform e o provider AWS.
###############################################################

terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

###############################################################
# Provider AWS
###############################################################

provider "aws" {
  region = "us-east-1"
}

###############################################################
# Availability Zones
###############################################################

data "aws_availability_zones" "available" {
  state = "available"
}

###############################################################
# VPC
###############################################################

resource "aws_vpc" "atividade3_vpc" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "atividade3-vpc"
  }

}

###############################################################
# Internet Gateway
###############################################################

resource "aws_internet_gateway" "atividade3_igw" {

  vpc_id = aws_vpc.atividade3_vpc.id

  tags = {
    Name = "atividade3-igw"
  }

}

###############################################################
# Public Subnet 1
###############################################################

resource "aws_subnet" "public_subnet_1" {

  vpc_id                  = aws_vpc.atividade3_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "atividade3-public-subnet-1"
  }

}

###############################################################
# Public Subnet 2
###############################################################

resource "aws_subnet" "public_subnet_2" {

  vpc_id                  = aws_vpc.atividade3_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "atividade3-public-subnet-2"
  }

}

###############################################################
# Route Table
###############################################################

resource "aws_route_table" "public_route_table" {

  vpc_id = aws_vpc.atividade3_vpc.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.atividade3_igw.id

  }

  tags = {
    Name = "atividade3-public-route-table"
  }

}

###############################################################
# Route Table Association - Public Subnet 1
###############################################################

resource "aws_route_table_association" "public_subnet_1_association" {

  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id

}

###############################################################
# Route Table Association - Public Subnet 2
###############################################################

resource "aws_route_table_association" "public_subnet_2_association" {

  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id

}

###############################################################
# Busca a AMI mais recente do Amazon Linux 2023
###############################################################

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

}

###############################################################
# Security Group
###############################################################

resource "aws_security_group" "atividade3_sg" {

  name        = "atividade3-security-group"
  description = "Security Group da atividade 3"
  vpc_id      = aws_vpc.atividade3_vpc.id

  #############################################################
  # SSH
  #############################################################

  ingress {

    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  #############################################################
  # HTTP
  #############################################################

  ingress {

    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  #############################################################
  # Saída
  #############################################################

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "atividade3-security-group"
  }

}

###############################################################
# EC2
###############################################################

resource "aws_instance" "atividade3_ec2" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.atividade3_sg.id
  ]

  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash

dnf update -y

dnf install -y httpd

systemctl enable httpd

systemctl start httpd

echo "<h1>Servidor criado com Terraform!</h1>" > /var/www/html/index.html

EOF

  tags = {
    Name = "atividade3-ec2"
  }

}

###############################################################
# Target Group
# Define para quais instâncias EC2 o Load Balancer enviará
# as requisições HTTP.
###############################################################

resource "aws_lb_target_group" "atividade3_tg" {

  name     = "atividade3-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.atividade3_vpc.id

  health_check {

    path     = "/"
    protocol = "HTTP"
    matcher  = "200"

  }

  tags = {
    Name = "atividade3-target-group"
  }

}

###############################################################
# Associação da EC2 ao Target Group
###############################################################

resource "aws_lb_target_group_attachment" "atividade3_attachment" {

  target_group_arn = aws_lb_target_group.atividade3_tg.arn

  target_id = aws_instance.atividade3_ec2.id

  port = 80

}

###############################################################
# Application Load Balancer
###############################################################

resource "aws_lb" "atividade3_alb" {

  name               = "atividade3-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.atividade3_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "atividade3-alb"
  }

}

###############################################################
# Listener
# Escuta requisições HTTP na porta 80 e as encaminha
# para o Target Group.
###############################################################

resource "aws_lb_listener" "atividade3_listener" {

  load_balancer_arn = aws_lb.atividade3_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.atividade3_tg.arn

  }

}

###############################################################
# DB Subnet Group
# Define em quais subnets o banco de dados poderá ser criado.
###############################################################

resource "aws_db_subnet_group" "atividade3_db_subnet_group" {

  name = "atividade3-db-subnet-group"

  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "atividade3-db-subnet-group"
  }

}

###############################################################
# Banco de Dados RDS
# Cria uma instância MySQL para armazenar os dados da aplicação.
###############################################################

resource "aws_db_instance" "atividade3_rds" {

  identifier = "atividade3-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name = "atividade3"

  username = "admin"

  password = "SenhaForte123!"

  db_subnet_group_name = aws_db_subnet_group.atividade3_db_subnet_group.name

  vpc_security_group_ids = [
    aws_security_group.atividade3_sg.id
  ]

  publicly_accessible = false

  skip_final_snapshot = true

  tags = {
    Name = "atividade3-rds"
  }

}
