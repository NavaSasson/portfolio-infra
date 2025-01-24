# This file sets up the VPC (Virtual Private Cloud) and related networking components.

# Creates a VPC 
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "nava-k8s-vpc"
    Environment = var.environment
  }
}

# Creates 2 public subnets:
#    CIDR blocks: Derived dynamically using cidrsubnet (splits the VPC range into subnets).
#    Availability zones: Assigned alternately between ap-south-1a and ap-south-1b.
#    map_public_ip_on_launch = true: Ensures instances launched in these subnets get public IPs.
resource "aws_subnet" "public_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.k8s_vpc.cidr_block, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "nava-public-subnet-${count.index}"
    Environment = var.environment
  }
}

# Creates 2 private subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.k8s_vpc.cidr_block, 8, count.index + 2)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "nava-private-subnet-${count.index}"
    Environment = var.environment
  }
}

# Attaches an internet gateway to the VPC, enabling public internet access.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  
  tags = {
    Name = "nava-igw"
    Environment = var.environment
  }
}

# A route table for public subnets, routing traffic to the internet gateway.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "nava-public-route-table"
    Environment = var.environment
  }
}

# Associates each public subnet with the public route table
resource "aws_route_table_association" "public_associations" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}