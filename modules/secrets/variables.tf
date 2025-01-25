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