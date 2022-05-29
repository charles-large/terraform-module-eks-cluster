terraform {
  
  required_version = ">= 0.13"
  
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

resource "aws_iam_role_policy" "efs-csi" {
  name = "${var.eks_cluster_name}-efs-csi-policy"
  role = aws_iam_role.efs-csi.name
  policy = jsonencode(
    {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
  )
}


resource "aws_iam_role" "efs-csi" {
  name = "${var.eks_cluster_name}-efs_csi"
  description = "IAM Role for EFS CSI in EKS Pod"
  assume_role_policy = data.aws_iam_policy_document.oidc_policy.json

}

data "aws_iam_policy_document" "oidc_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc-url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }

    principals {
      identifiers = [var.oidc-arn]
      type        = "Federated"
    }
  }
}

resource "helm_release" "efs_csi" {
  name = "efs-csi"
  namespace = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart = "aws-efs-csi-driver"
  set {
    name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.efs-csi.arn}"
  }

  set {
    name = "fullnameOverride"
    value = "efs-csi"
  }
  
}

# resource "kubectl_manifest" "efs_sc" {
#   yaml_body = templatefile("${path.module}/yaml_manifests/efs_sc.yaml", {efs_id = var.efs-id })
# }

resource "helm_release" "efs_sc" {
  name = "efs-sc"
  chart = "${path.module}/yaml_manifests/efs-sc"
  set {
    name = "efs_id"
    value = var.efs-id
  }
  
}