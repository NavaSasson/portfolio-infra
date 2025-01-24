# output "cluster_endpoint" {
#   description = "Endpoint for EKS cluster"
#   value       = module.eks.cluster_endpoint
# }

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}