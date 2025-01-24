# A complete Terraform configuration for your EKS cluster with the following components:

Main configuration (main.tf):

Defines local variables and tags
Calls the VPC, EKS, and security group modules

Providers configuration (providers.tf):
Sets up the AWS provider

Variables (variables.tf):

Defines all necessary variables with defaults
Configured for the ap-south-1 region to match your Jenkins pipeline


VPC Module (modules/vpc/main.tf):

Creates a VPC with CIDR 10.0.0.0/16
Sets up 2 public subnets (10.0.0.0/24, 10.0.1.0/24)
Sets up 2 private subnets (10.0.2.0/24, 10.0.3.0/24)
Creates an Internet Gateway for public subnets
Sets up appropriate route tables and associations


EKS Module (modules/eks/main.tf):

Creates the EKS cluster
Sets up necessary IAM roles and policies
Creates a node group with t3a.medium instances
Configures the cluster for 2-3 nodes as specified


To use this configuration:
terraform init
terraform plan -var-file=dev.tfvars -var-file=secrets.tfvars
terraform apply -var-file=dev.tfvars -var-file=secrets.tfvars
terraform destroy -var-file=dev.tfvars -var-file=secrets.tfvars

The directory structure:
# terraform/
# ├── main.tf           # Main configuration
# ├── variables.tf      # Root variables
# ├── providers.tf      # Provider and backend configuration
# ├── outputs.tf
# ├── dev.tfvars 
# ├── modules/
#     ├── vpc/
#     │   ├── main.tf        # VPC resources
#     |   ├── outputs.tf 
#     │   └── variables.tf
#     ├── eks/
#     │   ├── main.tf        # EKS resources
#     |   ├── outputs.tf
#     │   └── variables.tf
#     ├── storage/
#     │   ├── main.tf
#     |   ├── outputs.tf
#     │   └── variables.tf
#     └── secrets/
#         ├── main.tf        
#         ├── outputs.tf
#         └── variables.tf
