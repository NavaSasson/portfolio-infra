module "secrets" {
  source = "./modules/secrets"
  
  environment         = var.environment
  mongodb_username    = var.mongodb_username
  mongodb_password    = var.mongodb_password
  mongodb_root_password = var.mongodb_root_password
  mongodb_replica_set_key = var.mongodb_replica_set_key
  git_username       = var.git_username
  git_token          = var.git_token
  server_secretkey   = var.server_secretkey
  argocd_admin_password = var.argocd_admin_password

  depends_on = [ module.eks ]
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name         = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnet_ids
  instance_types      = var.instance_types
  scaling_config      = var.scaling_config

  depends_on = [ module.vpc ]
}

module "storage" {
  source = "./modules/storage"

  cluster_name = var.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  eks_oidc_provider_url = module.eks.oidc_provider_url

  depends_on = [module.eks]
}

module "argocd" {
  source = "./modules/argocd"
  
  gitops_repo_url = var.gitops_repo_url
  aws_region      = var.aws_region
  cluster_name    = var.cluster_name
  git_username = var.git_username
  git_token    = var.git_token
  sync_options = var.sync_options
  namespace = module.secrets.argocd_namespace

  depends_on = [ module.secrets ]
}