# # modules/argocd/main.tf

# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# resource "helm_release" "argocd" {
#   name       = "argocd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   namespace  = kubernetes_namespace.argocd.metadata[0].name
#   version    = "5.51.6"  # Specify your desired version

#   values = [
#     jsonencode({
#       server = {
#         service = {
#           type = "LoadBalancer"
#         }
#         ingress = {
#           enabled = true
#           annotations = {
#             "kubernetes.io/ingress.class" = "nginx"
#           }
#         }
#       }
#       configs = {
#         repositories = {
#           recipe-app-gitops = {
#             url = "https://github.com/NavaSasson/gitops-config.git"
#             type = "git"
#           }
#         }
#       }
#     })
#   ]
# }

# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = "argocd"
#   create_namespace = true
#   version          = "5.46.7"  # Specify your desired version

#   values = [
#     file("${path.module}/values.yaml")
#   ]

#   depends_on = [kubernetes_namespace.argocd]
# }

# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# # Root application for apps of apps pattern
# resource "kubernetes_manifest" "root_application" {
#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name      = "root-app"
#       namespace = "argocd"
#     }
#     spec = {
#       project = "default"
#       source = {
#         repoURL        = var.gitops_repo_url
#         targetRevision = "HEAD"
#         path           = "apps"
#       }
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = "argocd"
#       }
#       syncPolicy = {
#         automated = {
#           prune    = true
#           selfHeal = true
#         }
#       }
#     }
#   }

#   depends_on = [helm_release.argocd]
# }

# modules/argocd/main.tf
# modules/argocd/main.tf

# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = kubernetes_namespace.argocd.metadata[0].name
#   create_namespace = true
#   version          = "5.46.7"

#   values = [
#     jsonencode({
#       server = {
#         service = {
#           type = "LoadBalancer"
#         }
#         ingress = {
#           enabled = true
#           annotations = {
#             "kubernetes.io/ingress.class" = "nginx"
#           }
#         }
#       }
#       configs = {
#         repositories = {
#           "recipe-app-gitops" = {
#             url = var.gitops_repo_url
#             type = "git"
#           }
#         }
#       }
#       # Ensure CRDs are installed
#       crds = {
#         install = true
#         keep = true
#       }
#     })
#   ]
# }

# # Wait for the CRD to be available
# resource "time_sleep" "wait_for_crds" {
#   depends_on = [helm_release.argocd]
#   create_duration = "30s"
# }

# # Root application
# resource "kubernetes_manifest" "root_application" {
#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind = "Application"
#     metadata = {
#       name = "root-app"
#       namespace = "argocd"
#     }
#     spec = {
#       project = "default"
#       source = {
#         repoURL = var.gitops_repo_url
#         targetRevision = "HEAD"
#         path = "apps"
#       }
#       destination = {
#         server = "https://kubernetes.default.svc"
#         namespace = "argocd"
#       }
#       syncPolicy = {
#         automated = {
#           prune = true
#           selfHeal = true
#         }
#       }
#     }
#   }
#   depends_on = [
#     helm_release.argocd,
#     time_sleep.wait_for_crds
#   ]
# }

# modules/argocd/main.tf

# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = kubernetes_namespace.argocd.metadata[0].name
#   create_namespace = true
#   version          = "5.46.7"

#   values = [
#     jsonencode({
#       server = {
#         service = {
#           type = "LoadBalancer"
#         }
#         ingress = {
#           enabled = true
#           annotations = {
#             "kubernetes.io/ingress.class" = "nginx"
#           }
#         }
#       }
#       configs = {
#         repositories = {
#           "recipe-app-gitops" = {
#             url = var.gitops_repo_url
#             type = "git"
#           }
#         }
#       }
#       crds = {
#         install = true
#         keep = true
#       }
#     })
#   ]
# }

# # Wait for ArgoCD to be ready
# resource "null_resource" "wait_for_argo" {
#   depends_on = [helm_release.argocd]

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Waiting for ArgoCD to be ready..."
#       kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
#       kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
#       kubectl wait --for=condition=available --timeout=300s deployment/argocd-redis -n argocd
#       kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd
#     EOT
#   }
# }

# # Create the root application using kubectl
# resource "null_resource" "root_application" {
#   depends_on = [null_resource.wait_for_argo]

#   triggers = {
#     manifest_sha1 = sha1(jsonencode({
#       apiVersion = "argoproj.io/v1alpha1"
#       kind       = "Application"
#       metadata = {
#         name      = "root-app"
#         namespace = "argocd"
#       }
#       spec = {
#         project = "default"
#         source = {
#           repoURL        = var.gitops_repo_url
#           targetRevision = "HEAD"
#           path          = "apps"
#         }
#         destination = {
#           server    = "https://kubernetes.default.svc"
#           namespace = "argocd"
#         }
#         syncPolicy = {
#           automated = {
#             prune     = true
#             selfHeal  = true
#           }
#         }
#       }
#     }))
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       cat <<EOF | kubectl apply -f -
#       apiVersion: argoproj.io/v1alpha1
#       kind: Application
#       metadata:
#         name: root-app
#         namespace: argocd
#       spec:
#         project: default
#         source:
#           repoURL: ${var.gitops_repo_url}
#           targetRevision: HEAD
#           path: apps
#         destination:
#           server: https://kubernetes.default.svc
#           namespace: argocd
#         syncPolicy:
#           automated:
#             prune: true
#             selfHeal: true
#       EOF
#     EOT
#   }
# }


# modules/argocd/main.tf
# modules/argocd/main.tf

# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = kubernetes_namespace.argocd.metadata[0].name
#   create_namespace = true
#   version          = "5.46.7"

#   values = [
#     jsonencode({
#       server = {
#         service = {
#           type = "LoadBalancer"
#         }
#         ingress = {
#           enabled = true
#           annotations = {
#             "kubernetes.io/ingress.class" = "nginx"
#           }
#         }
#       }
#       configs = {
#         repositories = {
#           "recipe-app-gitops" = {
#             url = var.gitops_repo_url
#             type = "git"
#           }
#         }
#       }
#       crds = {
#         install = true
#         keep = true
#       }
#     })
#   ]
# }


# # Create GitHub credentials secret
# resource "kubernetes_secret" "git_credentials" {
#   metadata {
#     name      = "git-credentials"
#     namespace = var.namespace
#   }

#   data = {
#     username = var.git_username
#     password = var.git_token  # This should be a Personal Access Token
#   }
# }

# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace = var.namespace
#   create_namespace = false
#   version          = "7.7.16"

#   values = [
#     jsonencode({
#       server = {
#         service = {
#           type = "LoadBalancer"
#         }
#         ingress = {
#           enabled = true
#           annotations = {
#             "kubernetes.io/ingress.class" = "nginx"
#           }
#         }
#         extraArgs = [
#           "--insecure"
#         ]
#       }
#       configs = {
#         secret = {
#           createSecret = false
#         }
#         cm = {
#           "timeout.reconciliation" = "180s"
#           "application.instanceLabelKey" = "argocd.argoproj.io/instance"
#           "repositories" = yamlencode({
#             "recipe-app-gitops" = {
#               url = var.gitops_repo_url
#               type = "git"
#               usernameSecret = {
#                 name = "git-credentials"
#                 key = "username"
#               }
#               passwordSecret = {
#                 name = "git-credentials"
#                 key = "password"
#               }
#             }
#           })
#         }
#       }
#       crds = {
#         install = true
#         keep = true
#       }
#     })
#   ]

#   # depends_on = [kubernetes_secret.git_credentials]
# }

# resource "helm_release" "argocd" {
#   name       = "argocd"
#   namespace  = var.namespace
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   version    = "7.7.16"

#    values = [
#     <<-EOT
#     server:
#       service:
#         type: ClusterIP
#       extraArgs:
#         - --insecure
#     configs:
#       cm:
#         timeout.reconciliation: 180s
#         application.instanceLabelKey: argocd.argoproj.io/instance
#         repositories: |
#           - type: git
#             url: ${var.gitops_repo_url}
#             usernameSecret:
#               name: git-credentials
#               key: username
#             passwordSecret:
#               name: git-credentials
#               key: password
#     EOT
#   ]
# }
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

# Wait for ArgoCD to be ready with retries and better error handling
# resource "null_resource" "wait_for_argo" {
#   depends_on = [helm_release.argocd]

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Verifying cluster connectivity..."
#       kubectl cluster-info
#       if [ $? -ne 0 ]; then
#         echo "Updating kubeconfig..."
#         aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}
#       fi
      
#       echo "Waiting for ArgoCD to be ready..."
#       max_attempts=10
#       attempt=1
      
#       while [ $attempt -le $max_attempts ]; do
#         echo "Attempt $attempt of $max_attempts..."
        
#         if kubectl get deployment -n argocd argocd-server >/dev/null 2>&1; then
#           echo "Checking deployments..."
          
#           # Check each deployment individually and print status
#           deployments_ready=true
          
#           for deployment in argocd-server argocd-repo-server argocd-applicationset-controller argocd-notifications-controller; do
#             echo "Checking $deployment..."
#             if kubectl wait --for=condition=available --timeout=60s deployment/$deployment -n argocd >/dev/null 2>&1; then
#               echo "$deployment is ready"
#             else
#               echo "$deployment is not ready"
#               deployments_ready=false
#               break
#             fi
#           done
          
#           if [ "$deployments_ready" = true ]; then
#             echo "All ArgoCD deployments are ready!"
#             exit 0
#           fi
#         else
#           echo "ArgoCD deployments not found yet, waiting..."
#         fi
        
#         attempt=$((attempt + 1))
#         [ $attempt -le $max_attempts ] && echo "Waiting 30 seconds before next attempt..." && sleep 30
#       done
      
#       echo "Timed out waiting for ArgoCD"
#       echo "Current deployment status:"
#       kubectl get deployments -n argocd
#       exit 1
#     EOT
#   }
# }

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

# Root application
# resource "kubernetes_manifest" "root_application" {
#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind = "Application"
#     metadata = {
#       name = "root-app"
#       namespace = "argocd"
#     }
#     spec = {
#       project = "default"
#       source = {
#         repoURL = var.gitops_repo_url
#         targetRevision = "HEAD"
#         path = "apps"
#       }
#       destination = {
#         server = "https://kubernetes.default.svc"
#         namespace = "recipe-app"
#       }
#       syncPolicy = {
#         automated = {
#           prune = true
#           selfHeal = true
#         }
#       }
#     }
#   }
#   depends_on = [
#     null_resource.wait_for_argo
#   ]
# }

# resource "null_resource" "root_application" {
#   depends_on = [null_resource.wait_for_argo]

#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     command = <<-EOT
#       cat > argocd_app.yaml << 'INNEREOF'
#       apiVersion: argoproj.io/v1alpha1
#       kind: Application
#       metadata:
#         name: root-app
#         namespace: ${var.namespace}
#       spec:
#         project: default
#         source:
#           repoURL: ${var.gitops_repo_url}
#           targetRevision: HEAD
#           path: apps
#         destination:
#           server: https://kubernetes.default.svc
#           namespace: ${var.app_namespace}
#         syncPolicy:
#           automated:
#             prune: true
#             selfHeal: true
# INNEREOF
#       kubectl apply -f argocd_app.yaml
#     EOT
#   }
# }

# resource "null_resource" "verify_application" {
#   depends_on = [null_resource.root_application]

#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "Verifying Application creation..."
#       kubectl wait --for=condition=available --timeout=60s application/root-app -n ${var.namespace}
#       kubectl get application root-app -n ${var.namespace} -o jsonpath='{.status.sync.status}'
#     EOT
#   }
# }
# resource "null_resource" "root_application" {
#   depends_on = [null_resource.wait_for_argo]

#   triggers = {
#     manifest_sha1 = sha1(jsonencode({
#       apiVersion = "argoproj.io/v1alpha1"
#       kind = "Application"
#       metadata = {
#         name = "root-app"
#         namespace = var.namespace
#       }
#       spec = {
#         project = "default"
#         source = {
#           repoURL = var.gitops_repo_url
#           targetRevision = "HEAD"
#           path = "apps"
#         }
#         destination = {
#           server = "https://kubernetes.default.svc"
#           namespace = var.app_namespace
#         }
#         syncPolicy = {
#           automated = {
#             prune = true
#             selfHeal = true
#           }
#         }
#       }
#     }))
#   }

#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     command = <<-EOT
#       cat > argocd_app.yaml << 'INNEREOF'
#       apiVersion: argoproj.io/v1alpha1
#       kind: Application
#       metadata:
#         name: root-app
#         namespace: ${var.namespace}
#       spec:
#         project: default
#         source:
#           repoURL: ${var.gitops_repo_url}
#           targetRevision: HEAD
#           path: apps
#         destination:
#           server: https://kubernetes.default.svc
#           namespace: ${var.app_namespace}
#         syncPolicy:
#           automated:
#             prune: true
#             selfHeal: true
# INNEREOF
#       kubectl apply -f argocd_app.yaml
#     EOT
#   }
# }