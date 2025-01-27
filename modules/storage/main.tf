# Configuring the resources needed to run the Amazon EBS CSI Driver on EKS
# The CSI Driver is a container storage interface that allows Kubernetes to communicate with external storage systems

# Create IAM role and policy
# Allows him to direct access through Web Identity (OIDC) in EKS.
resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.cluster_name}-ebs-csi-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider_url}:aud": "sts.amazonaws.com",
            "${var.eks_oidc_provider_url}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Attaches the IAM policy (AmazonEBSCSIDriverPolicy) to the ebs_csi_role role.
# Gives access to CSI so that it can perform operations related to managing EBS volumes in AWS.
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

# Installing the EBS CSI Driver on EKS as ADD-ON
resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version              = "v1.31.0-eksbuild.1"
  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  
  depends_on = [aws_iam_role_policy_attachment.ebs_csi_policy]

  tags = {
    "eks_addon" = "ebs-csi"
  }
}

# Create default storage class
resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "nava-ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [aws_eks_addon.ebs_csi]
}

