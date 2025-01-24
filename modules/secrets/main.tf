# resource "aws_secretsmanager_secret" "mongodb_secret" {
#   name = "nava-recipe-app-secrets"

#   lifecycle {
#     prevent_destroy = true
#     ignore_changes = [name]
#   }
# }

data "aws_secretsmanager_secret" "mongodb_secret" {
  name = "nava-recipe-app-secrets"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_namespace" "recipe-app" {
  metadata {
    name = "recipe-app"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

data "aws_secretsmanager_secret_version" "mongodb_secret" {
  secret_id = data.aws_secretsmanager_secret.mongodb_secret.id
  depends_on = [aws_secretsmanager_secret_version.mongodb_secret_version]
}

resource "aws_secretsmanager_secret_version" "mongodb_secret_version" {
  secret_id     = data.aws_secretsmanager_secret.mongodb_secret.id
  secret_string = jsonencode({
    "username"                = var.mongodb_username,
    "password"                = var.mongodb_password,
    "root_password"           = var.mongodb_root_password,
    "replica_set_key"         = var.mongodb_replica_set_key,
    "argocd_server_secretkey" = var.server_secretkey,
    "argocd_admin_password"   = var.argocd_admin_password,
    "argocd_admin_passwordMtime" = timestamp(),
    "git_username"            = var.git_username,
    "git_token"               = var.git_token
  })
}

resource "kubernetes_secret" "git_credentials" {
  metadata {
    name      = "git-credentials"
    namespace = "argocd"
  }
  data = {
    username = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["git_username"]
    password = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["git_token"]
  }
  type = "Opaque"
}

resource "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-admin-secret"
    namespace = "argocd"
  }
  data = {
    "admin.password"      = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["argocd_admin_password"]
    "admin.passwordMtime" = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["argocd_admin_passwordMtime"]
    "server.secretkey"    = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["argocd_server_secretkey"]
  }
  type = "Opaque"
  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_secret" "mongodb_secret" {
  metadata {
    name      = "mongodb-secret"
    namespace = "recipe-app"
  }
  data = {
    "mongodb-username"        = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["username"]
    "mongodb-passwords"       = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["password"]
    "mongodb-root-password"   = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["root_password"]
    "mongodb-replica-set-key" = jsondecode(data.aws_secretsmanager_secret_version.mongodb_secret.secret_string)["replica_set_key"]
  }
  type = "Opaque"
  depends_on = [kubernetes_namespace.recipe-app]
}