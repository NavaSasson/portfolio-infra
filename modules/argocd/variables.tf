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

variable "namespace" {
  description = "namespace for argocd"
  type = string
}

variable "sync_options" {
  type    = list(string)
}