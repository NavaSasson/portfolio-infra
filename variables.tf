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

variable "gitops_repo_url" {
  description = "URL of the GitOps repository"
  type        = string
}

variable "sync_options" {
  type    = list(string)
}