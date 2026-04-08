terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "trend_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "trend-vpc" }
}

# Public Subnet
resource "aws_subnet" "trend_public_subnet" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "trend-public-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id
  tags = { Name = "trend-igw" }
}

# Route Table
resource "aws_route_table" "trend_rt" {
  vpc_id = aws_vpc.trend_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }
  tags = { Name = "trend-rt" }
}

resource "aws_route_table_association" "trend_rta" {
  subnet_id      = aws_subnet.trend_public_subnet.id
  route_table_id = aws_route_table.trend_rt.id
}

# Security Group
resource "aws_security_group" "trend_sg" {
  name   = "trend-sg"
  vpc_id = aws_vpc.trend_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
  tags = { Name = "trend-sg" }
}

# IAM Role for EC2
resource "aws_iam_role" "trend_ec2_role" {
  name = "trend-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "trend_ec2_policy" {
  role       = aws_iam_role.trend_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "trend_profile" {
  name = "trend-ec2-profile"
  role = aws_iam_role.trend_ec2_role.name
}

# EC2 Jenkins
resource "aws_instance" "trend_jenkins" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.trend_public_subnet.id
  vpc_security_group_ids = [aws_security_group.trend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.trend_profile.name
  key_name               = "trend-key"

  user_data = <<-USERDATA
    #!/bin/bash
    apt-get update -y
    apt-get install -y openjdk-17-jdk
    mkdir -p /opt/jenkins
    wget -O /opt/jenkins/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war
    useradd -m -s /bin/bash jenkins
    mkdir -p /var/lib/jenkins
    chown -R jenkins:jenkins /var/lib/jenkins /opt/jenkins
    cat > /etc/systemd/system/jenkins.service << 'SVC'
[Unit]
Description=Jenkins
After=network.target
[Service]
Type=simple
User=jenkins
Environment="JAVA_OPTS=-Xmx1024m -Xms512m"
Environment="JENKINS_HOME=/var/lib/jenkins"
ExecStart=/usr/bin/java $JAVA_OPTS -jar /opt/jenkins/jenkins.war --httpPort=8080
Restart=on-failure
[Install]
WantedBy=multi-user.target
SVC
    systemctl daemon-reload
    systemctl enable jenkins
    systemctl start jenkins
  USERDATA

  tags = { Name = "trend-jenkins-server" }
}

output "jenkins_public_ip" {
  value = aws_instance.trend_jenkins.public_ip
}
