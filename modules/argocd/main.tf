# Define required providers for Helm and Kubectl
terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

# Add ArgoCD Helm release resource
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.16" 

  values = [
    <<-EOT
    server:
      service:
        type: ClusterIP
      extraArgs:
        - --insecure
    configs:
      cm:
        timeout.reconciliation: 180s
        application.instanceLabelKey: argocd.argoproj.io/instance
        repositories: |
          - type: git
            url: ${var.gitops_repo_url}
            usernameSecret:
              name: git-credentials
              key: username
            passwordSecret:
              name: git-credentials
              key: password
    # Ensure CRDs are installed
    crds:
      install: true
      keep: true
    EOT
  ]
}

# Create Kubernetes manifest for ArgoCD root application
resource "kubectl_manifest" "argocd_application_infra_app" {
  yaml_body = templatefile("${path.module}/templates/root_app.yaml.tpl", {
    name = "root-app"
    namespace       = var.namespace
    repo_url        = var.gitops_repo_url
    infra_namespace = var.namespace
    infra_path      = "apps"
    sync_options    = var.sync_options
  })
  depends_on = [helm_release.argocd]
}