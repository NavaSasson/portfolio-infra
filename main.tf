module "secrets" {
  source = "./modules/secrets"

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
  sync_options = var.sync_options
  namespace = module.secrets.argocd_namespace

  depends_on = [ module.secrets ]
}