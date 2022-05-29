resource "helm_release" "metrics" {
  name = "metrics"
  namespace = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "metrics-server"
  
}