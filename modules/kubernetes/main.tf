# terraform {
  
#   required_version = ">= 0.13"
  
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 3.20.0"
#     }

#     kubectl = {
#       source  = "gavinbunney/kubectl"
#       version = ">= 1.7.0"
#     }
#   }
# }


data "terraform_remote_state" "efs" {
  backend = "s3"

  config = {
      bucket = "tf-eks-states"
      key    = "efs/terraform.tfstate"
      region = "us-west-2"
  }
}

module "ebs-csi" {
    count = "${var.ebs-csi ? 1 : 0}"
    source = "./ebs_csi/"
    eks_cluster_name = var.cluster_name
    oidc-url = var.oidc-url
    oidc-arn = var.oidc-arn
    
  
}

module "efs-csi" {
  count = "${var.efs-csi ? 1 : 0}"
  source = "./efs_csi/"
  eks_cluster_name = var.cluster_name
  oidc-url = var.oidc-url
  oidc-arn = var.oidc-arn
  efs-id = var.efs-id
  efs-access-point-id = var.efs-access-point-id

}

module "metric-server" {
    count = "${var.metric-server ? 1 : 0}"
    source = "./metrics_server/"
}

module "aws-alb-controller" {
  count = "${var.aws-alb-controller ? 1 : 0}"
  source = "./aws_alb_controller/"
  eks_cluster_name = var.cluster_name
  vpc-id = var.vpc-id
  oidc-url = var.oidc-url
  oidc-arn = var.oidc-arn
}

module "aws-fluent-bit" {
    count = "${var.aws-fluent-bit ? 1 : 0}"
    source = "./fluent_bit/"
    eks_region = var.region
    eks_cluster_name = var.cluster_name
    oidc-url = var.oidc-url
    oidc-arn = var.oidc-arn
}

module "coredns" {
  source = "./coredns"
  count = "${var.coredns ? 1 : 0}"
}


