locals {
  k8s_sa_lb_name      = "aws-load-balancer-controller"
  k8s_sa_lb_namespace = "kube-system"
}

resource "kubernetes_service_account" "loadbalancer_controller" {
  metadata {
    name      = local.k8s_sa_lb_name
    namespace = local.k8s_sa_lb_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_loadbalancer_controller.iam_role_arn
    }
  }
}

resource "helm_release" "loadbalancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"
  namespace  = local.k8s_sa_lb_namespace

  set {
    name  = "clusterName"
    value = var.environment_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = local.k8s_sa_lb_name
  }
}
