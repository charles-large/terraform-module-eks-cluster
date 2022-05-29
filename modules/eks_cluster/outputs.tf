output "endpoint" {
  value = aws_eks_cluster.primary_eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.primary_eks_cluster.certificate_authority[0].data
}

output "cluster_id" {
  value = aws_eks_cluster.primary_eks_cluster.id
}

output "oidc-arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc-url"{
value = aws_iam_openid_connect_provider.oidc.url
}

output "eks_cluster_sg" {
  value = aws_security_group.eks_cluster_main_sg.id
  
}