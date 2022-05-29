resource "kubernetes_namespace" "amazon-cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
  }
}


resource "helm_release" "aws-cloudwatch-metrics" {
  name = "aws-cloudwatch-metrics"
  repository = "https://aws.github.io/eks-charts/"
  namespace = "amazon-cloudwatch"
  chart = "aws-cloudwatch-metrics"

  set {
    name = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.fluentbit.arn}"
  }
}