# resource "helm_release" "aws_cni" {
#   name = "aws-cni"
#   namespace = "kube-system"
#   repository = "https://aws.github.io/eks-charts/"
#   chart = "aws-vpc-cni"
#   set {
#     name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = "${aws_iam_role.aws_alb_controller.arn}"
#   }

#   set {
#     name = "image.region"
#     value = var.region
#   }
  
#   set {
#     name = "init.image.region"
#     value = var.region
#   }

#   set {
#     name = "fullnameOverride"
#     value = "aws-load-balancer-controller"
#   }
  
# }