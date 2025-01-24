# modules/secrets/variables.tf

variable "environment" {
  description = "Environment name"
  type        = string
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

# variable "eks_worker_role_name" {
#   description = "Name of the EKS worker nodes IAM role"
#   type        = string
# }

# variable "eks_oidc_provider_arn" {
#   description = "ARN of the EKS OIDC provider"
#   type        = string
# }

# variable "eks_cluster_id" {
#   description = "ID of the EKS cluster"
#   type        = string
# }


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

variable "git_username" {
  description = "Git username for ArgoCD"
  type        = string
  sensitive   = true
}

variable "git_token" {
  description = "Git token for ArgoCD"
  type        = string
  sensitive   = true
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