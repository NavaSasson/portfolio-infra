output "argocd_namespace" {
  description = "The name of the argocd namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}