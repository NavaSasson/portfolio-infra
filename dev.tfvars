# The AWS region where you want to create your resources
aws_region = "ap-south-1"

# Node configuration: number of nodes
scaling_config = {
  desired_size   = 3
  max_size       = 4
  min_size       = 2
}

# Node configuration: instances type
instance_types = ["t3a.medium"]

# CIDR block for the VPC
vpc_cidr           = "10.0.0.0/16"
cluster_name       = "nava-recipe-app-cluster"

# List of Availability Zones where resources will be created
availability_zones = ["ap-south-1a", "ap-south-1b"]

# The name of the environment (e.g., production, staging, development)
environment        = "dev"

# Default tags for resources
default_tags = {
    expiration_date = "01-04-2025"
    owner           = "nava.naane"
    bootcamp        = "BC22"
}

# gitops repo url: for argocd- apps of apps
gitops_repo_url = "https://github.com/NavaSasson/gitops-config.git"

sync_options = ["CreateNamespace=true", "ServerSideApply=true"]