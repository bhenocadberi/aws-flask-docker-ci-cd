# Specify the AWS provider and region
provider "aws" {
  region = "ap-southeast-2" # Or your preferred AWS region (e.g., "ap-southeast-1" for Singapore, common in Asia)
}

# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "flask-app-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true # Automatically assign public IP to instances
  availability_zone = "${aws_vpc.app_vpc.region}a" # Use AZ 'a' in your region
  tags = {
    Name = "flask-app-public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "flask-app-igw"
  }
}

# Create a Route Table and associate it with the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # Allow all outbound traffic
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "flask-app-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a Security Group for the EC2 instance
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.app_vpc.id
  name        = "flask-app-sg"
  description = "Allow HTTP and SSH inbound traffic"

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For prototyping. Restrict this in production!
  }

  # Allow HTTP access to your Flask app
  ingress {
    from_port   = 5000 # Flask default port
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For prototyping. Restrict this in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "flask-app-sg"
  }
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
