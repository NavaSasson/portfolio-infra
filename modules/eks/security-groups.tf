# This file defines security groups and rules.

# Security group for Kubernetes nodes
resource "aws_security_group" "k8s_sg" {
  name        = "nava-k8s-sg"
  description = "Security group for Kubernetes nodes"
  vpc_id      = var.vpc_id

# HTTPS communication (e.g., API server).
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Kubernetes API server traffic.
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Node-to-node communication for Kubernetes components.
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allows all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}