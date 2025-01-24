variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

# variable "security_group_ids" {
#   description = "List of security group IDs"
#   type        = list(string)
# }

variable "instance_types" {
  description = "Nodes EC2 types"
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