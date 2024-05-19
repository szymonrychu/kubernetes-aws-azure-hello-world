resource "kubernetes_service_account" "loadbalancer_controller" {
  metadata {
    name      = "test"
    namespace = "kube-system"
  }
}
