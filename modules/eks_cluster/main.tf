// General Cluster settings
resource "aws_eks_cluster" "primary_eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = var.eks_version
  
  
  vpc_config {
    subnet_ids = var.private_cluster ? [for x in var.eks_cluster_subnets: x.id if x.tags["public"] == "false"] : [for x in var.eks_cluster_subnets: x.id]
    # subnet_ids = [for x in var.eks_cluster_subnets: x.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access = var.endpoint_public_access
    security_group_ids = [aws_security_group.eks_cluster_main_sg.id]


  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_role-AmazonEKSVPCResourceController,
  ]

  

}

##################################################################################################################

// Cluster Role

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

##################################################################################################################

// OIDC setup

data "tls_certificate" "cert" {
  url = aws_eks_cluster.primary_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.primary_eks_cluster.identity[0].oidc[0].issuer

}

data "aws_iam_policy_document" "oidc_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

##################################################################################################################

// Security Groups

resource "aws_iam_role" "eks_oidc_role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_policy.json
  name               = "eks_oidc_role"
}

resource "aws_security_group" "eks_cluster_main_sg"{
  
  name        = "${var.eks_cluster_name}_cluster_sg"
  description = "Main SG for ${var.eks_cluster_name} EKS Cluster"
  vpc_id      = var.vpc_id
  ingress {
    description = "Traffic from Cluster Nodes and self"
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
}
}