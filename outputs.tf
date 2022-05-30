output "cluster_id" {
  value = module.eks_cluster.cluster_id
}

output "endpoint" {
  value = module.eks_cluster.endpoint
}

output "certificate" {
  value = module.eks_cluster.kubeconfig-certificate-authority-data
  
}

output "region" {
    value = var.region 
}

output "oidc-arn" {
  value = module.eks_cluster.oidc-arn
}

output "oidc-url"{
value = module.eks_cluster.oidc-url
}

output "managed_node_group_asg_name" {
  value = var.managed_node_group ? module.managed_node_group[0].asg_name : null
  
}

