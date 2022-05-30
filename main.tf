provider "kubernetes" {
  host                   = module.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.kubeconfig-certificate-authority-data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.kubeconfig-certificate-authority-data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    command     = "aws"
  }
  }
}

module "eks_cluster" {
  source = "./modules/eks_cluster"

  //EKS Cluster settings
  eks_cluster_name = var.eks_cluster_name
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access = var.endpoint_public_access
  eks_version = var.eks_version
  private_cluster = var.private_cluster
  vpc_id = var.vpc_id

  //EKS Cluster Networking
  eks_cluster_subnets = var.vpc_subnets 
}

module "managed_node_group" {
  source = "./modules/managed_node_group"
  count = var.managed_node_group && !var.fargate_cluster ? 1 : 0

  //EKS Cluster settings
  eks_cluster_name = var.eks_cluster_name
  private_cluster = var.private_cluster
  
  //EKS Cluster Networking
  eks_cluster_subnets = var.vpc_subnets 
  eks_cluster_sg = module.eks_cluster.eks_cluster_sg
  
  //Managed Node group settings
  node_group_name = var.node_group_name
  managed_node_group = var.managed_node_group
  disk_size = var.disk_size
  capacity_type = var.capacity_type
  instance_type = var.instance_type
  force_update_version = var.force_update_version
  timeouts = var.timeouts
  scaling_config = var.scaling_config
  update_config = var.update_config

  depends_on = [module.eks_cluster]

}

module "fargate" {
  source = "./modules/fargate"
  count = var.fargate_cluster && !var.managed_node_group ? 1 : 0

  //EKS Cluster settings
  eks_cluster_name = var.eks_cluster_name
  private_cluster = var.private_cluster
  
  //EKS Cluster Networking
  eks_cluster_subnets = var.vpc_subnets 
  eks_cluster_sg = module.eks_cluster.eks_cluster_sg

  depends_on = [module.eks_cluster]
  
}

module "kubernetes" {
  source = "./modules/kubernetes"
  region = var.region
  cluster_id = module.eks_cluster.cluster_id
  endpoint = module.eks_cluster.endpoint
  ca = module.eks_cluster.kubeconfig-certificate-authority-data
  cluster_name = module.eks_cluster.cluster_id
  oidc-arn = module.eks_cluster.oidc-arn
  oidc-url = module.eks_cluster.oidc-url
  vpc-id = var.vpc_id 

  // Drivers
  efs-csi = false
  ebs-csi = true
  metric-server = true
  aws-alb-controller = true
  aws-fluent-bit = false

  depends_on = [
    module.fargate, module.managed_node_group
  ]
}