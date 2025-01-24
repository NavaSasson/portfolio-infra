output "cluster_endpoint" {
  value = aws_eks_cluster.nava_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.nava_cluster.name
}

output "worker_role_name" {
  value = aws_iam_role.eks_worker_role.name
  description = "Name of the EKS worker nodes IAM role"
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${substr(aws_eks_cluster.nava_cluster.identity[0].oidc[0].issuer, 8, -1)}"
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider"
  value = replace(aws_eks_cluster.nava_cluster.identity[0].oidc[0].issuer, "https://", "")
}

output "k8s_security_group_id" {
  value = aws_security_group.k8s_sg.id
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.nava_cluster.certificate_authority[0].data
}