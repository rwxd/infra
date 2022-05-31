resource "kubernetes_namespace" "nginx-ingress-controller" {
  metadata {
    name = "nginx-ingress-controller"
  }
}

resource "helm_release" "nginx-ingress-controller" {
  name       = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "nginx-ingress-controller"
  version    = "4.1.3"

  depends_on = [helm_release.metallb, kubernetes_namespace.nginx-ingress-controller]

  values = [
    yamlencode({
      defaultBackend = {
        enabled = false
      }
    })
  ]
}
