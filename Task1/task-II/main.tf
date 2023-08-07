# main.tf

# Provider configuration for AWS
provider "aws" {
  region = "us-east-1" 
  profile= "profilename"
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect  = "Allow"
        Action  = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  name       = "eks-cluster-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.eks_cluster.name]
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "MainVPC"
  }
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" 

  tags = {
    Name = "PublicSubnet"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id
  allocation_id = aws_eip.nat[count.index].id
}

# Create Elastic IPs for NAT Gateway
resource "aws_eip" "nat" {
  count = length(aws_subnet.private)
}

# Create a Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a Route Table for Private Subnets
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "PrivateRouteTable-${count.index + 1}"
  }
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create a Security Group for Kubernetes Cluster
resource "aws_security_group" "k8s_cluster_sg" {
  name_prefix = "k8s-cluster-sg-"
  vpc_id      = aws_vpc.main.id

  # Inbound rule 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }
 # Inbound rule 
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create a Kubernetes Cluster using AWS EKS

resource "aws_eks_cluster" "k8s_cluster" {
  name     = "my-k8s-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

    vpc_config {
    subnet_ids = [
      aws_subnet.public.id,
      aws_subnet.private[0].id, 
      aws_subnet.private[1].id, 
    ]
    security_group_ids = [aws_security_group.k8s_cluster_sg.id]
  }
}

# Create a worker node group for the EKS cluster
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.k8s_cluster.name
  node_group_name = "worker-group"
  node_role_arn   = aws_iam_role.eks_cluster.arn

  subnet_ids       = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  instance_types   = ["t2.micro"]  # Replace with desired instance types

  scaling_config {
    desired_size = 2  
    min_size     = 1  
    max_size     = 3  
  }

}

# Outputs for convenience
output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.k8s_cluster.name
}
