resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn"
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = "longhorn"
  version    = "1.2.4"

  depends_on = [kubernetes_namespace.longhorn]

  values = [
    yamlencode({
    })
  ]
}


resource "kubernetes_ingress_v1" "longhorn_ingress" {
  metadata {
    name      = "longhorn-ingress"
    namespace = "longhorn"
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "cert-manager.io/cluster-issuer"           = "cluster-issuer-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  depends_on = [kubernetes_namespace.longhorn]

  spec {
    rule {
      host = "longhorn.k3s.rwxd.eu"
      http {
        path {
          backend {
            service {
              name = "longhorn-frontend"
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      secret_name = "longhorn-tls"
      hosts = [
        "longhorn.k3s.rwxd.eu"
      ]
    }
  }
}
