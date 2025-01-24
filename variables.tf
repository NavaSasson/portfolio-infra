variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "default_tags" {
  description = "Default tags for AWS resources"
  type        = map(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cider block"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "availability_zones" {
  description = "Cluster name"
  type        = list(string)
}

variable "instance_types" {
  description = "Nodes EC2 type"
  type        = list(string)
}

variable "scaling_config" {
  description = "Configuration for EKS node group"
  type = object({
    desired_size   = number
    max_size       = number
    min_size       = number
  })
}

variable "mongodb_username" {
  description = "MongoDB username"
  type        = string
  sensitive   = true
}

variable "mongodb_password" {
  description = "MongoDB password"
  type        = string
  sensitive   = true
}

variable "gitops_repo_url" {
  description = "URL of the GitOps repository"
  type        = string
}

variable "git_username" {
  description = "GitHub username for repository access"
  type        = string
  sensitive   = true
}

variable "git_token" {
  description = "GitHub personal access token for repository access"
  type        = string
  sensitive   = true
}

variable "mongodb_root_password" {
  description = "MongoDB root password"
  type        = string
  sensitive   = true
}

variable "mongodb_replica_set_key" {
  description = "MongoDB replica set key"
  type        = string
  sensitive   = true
}

# variable "recipe_api_key" {
#   description = "Recipe API key"
#   type        = string
#   sensitive   = true
# }

variable "server_secretkey" {
  description = "ArgoCD server secret key"
  type        = string
  sensitive   = true
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password"
  type        = string
  sensitive   = true
}

variable "sync_options" {
  type    = list(string)
}

# variable "aws_access_key_id" {
#   description = "AWS access key ID"
#   type        = string
#   sensitive   = true
# }

# variable "aws_secret_access_key" {
#   description = "AWS secret access key"
#   type        = string
#   sensitive   = true
# }

# variable "aws_default_region" {
#   description = "AWS default region"
#   type        = string
# }