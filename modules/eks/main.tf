# This file configures the EKS cluster and its resources.

data "aws_caller_identity" "current" {}


# Get the thumbprint for the EKS OIDC provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.nava_cluster.identity[0].oidc[0].issuer
}

# Create the OIDC provider
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.nava_cluster.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-eks-oidc"
  }
}

# Creates the Kubernetes cluster with:
#    Subnets: Public subnets for worker nodes.
#    Security group: Allows traffic between the cluster and nodes.
resource "aws_eks_cluster" "nava_cluster" {
  name     = var.cluster_name

  role_arn = aws_iam_role.eks_service_role.arn
  
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.k8s_sg.id ]
    # security_group_ids = var.security_group_ids
  }

  tags = {
    Name = var.cluster_name
  }
}

# IAM role for EKS control plane:
# Allows eks.amazonaws.com to assume the role.
resource "aws_iam_role" "eks_service_role" {
  name = "nava-eks-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
      }
    ]
  })
}

# AmazonEKSClusterPolicy: Grants permissions to manage the cluster.
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# AmazonVPCFullAccess: Grants access to networking resources (subnets, route tables).
resource "aws_iam_role_policy_attachment" "vpc_policy" {
  role       = aws_iam_role.eks_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.eks_worker_role.name
# }

resource "aws_launch_template" "eks_nodes" {
  name = "${var.cluster_name}-template"
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-worker"
      owner = "nava.naane"
      bootcamp = "BC22"
      expiration_date = "01-04-25"
    }
  }
}

# Configures the worker nodes for the EKS cluster:
#   Connects to the cluster and public subnets.
#   Uses an IAM role for worker nodes.
resource "aws_eks_node_group" "app_nodes" {
  cluster_name    = aws_eks_cluster.nava_cluster.name
  node_group_name = "nava-k8s-nodes"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = var.subnet_ids

  launch_template {
    id = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }

  instance_types = var.instance_types

  depends_on = [
    aws_eks_cluster.nava_cluster,
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.registry_policy,
  ]

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}



# IAM role for worker nodes:
# Allows ec2.amazonaws.com to assume the role.
resource "aws_iam_role" "eks_worker_role" {
  name = "nava-eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# AmazonEKSWorkerNodePolicy: Permissions for worker nodes to join the cluster.
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# AmazonEKS_CNI_Policy: Permissions for the networking plugin.
resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# AmazonEC2ContainerRegistryReadOnly: Read-only access to ECR for pulling container images.
resource "aws_iam_role_policy_attachment" "registry_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}