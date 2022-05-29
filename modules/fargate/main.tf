resource "aws_eks_fargate_profile" "fargate" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = "All"
  pod_execution_role_arn = aws_iam_role.fargate_execution.arn
  subnet_ids             = [for x in var.eks_cluster_subnets: x.id if x.tags["public"] == "false"]

  selector {
    namespace = "kube-system"
  }
}

resource "aws_iam_role" "fargate_execution" {
  name = "eks-fargate-profile-all"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_execution.name
}