# variable "eks_cluster_id" {
#   description = "ID of the EKS cluster"
#   type        = string
# }

variable "gitops_repo_url" {
  description = "url for argocd infra"
  type        = string
}


variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
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

variable "namespace" {
  description = "namespace for argocd"
  type = string
}

variable "sync_options" {
  type    = list(string)
}