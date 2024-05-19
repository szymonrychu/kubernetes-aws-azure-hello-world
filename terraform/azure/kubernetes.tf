resource "helm_release" "hello-world" {
  name = "hello-world"

  chart = "${path.module}/../../charts/hello-world"

  namespace = "default"

  values = [
    file("${path.module}/../../values/common.yaml"),
    file("${path.module}/../../values/azure/common.yaml"),
  ]
}
