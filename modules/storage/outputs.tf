output "ebs_storage_class_name" {
  value = kubernetes_storage_class.ebs_sc.metadata[0].name
}

output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi_role.arn
}