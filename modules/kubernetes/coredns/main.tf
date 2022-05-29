resource "helm_release" "core_dns" {
  name = "coredns"
  namespace = "kube-system"
  repository = "https://coredns.github.io/helm"
  chart = "coredns" 

  # set {
  #   name = "deployment.name"
  #   value = "coredns"
  # }

  // needs toleration for eks.amazonaws.com/compute-type=fargate:NoSchedule
}