resource "helm_release" "aws_for_fluent_bit" {
  name = "aws-for-fluent-bit"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts/"
  chart = "aws-for-fluent-bit"
  set {
    name = "cloudWatch.region"
    value = var.eks_region
  }

  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.fluentbit.arn}"
  }

  set {
    name = "firehose.enabled"
    value = false
  }
  
  set {
    name = "kinesis.enabled"
    value = false
  }

  set {
    name = "elasticsearch.enabled"
    value = false
  }
  
}

resource "aws_iam_role" "fluentbit" {
  name = "${var.eks_cluster_name}-fluentbit"
  description = "IAM Role for Fluentbit cloudwatch permissions"
  assume_role_policy = data.aws_iam_policy_document.oidc_policy.json

}

resource "aws_iam_role_policy_attachment" "CloudWatchServerAgentPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.fluentbit.name
}

data "aws_iam_policy_document" "oidc_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc-url, "https://", "")}:sub"
      values   = [
        "system:serviceaccount:kube-system:aws-for-fluent-bit",
        "system:serviceaccount:amazon-cloudwatch:aws-cloudwatch-metrics"]
    }

    principals {
      identifiers = [var.oidc-arn]
      type        = "Federated"
    }
  }
}
