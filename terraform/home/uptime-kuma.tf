resource "kubernetes_namespace" "uptime-kuma" {
  metadata {
    name = "uptime-kuma"
  }
}

resource "helm_release" "uptime-kuma" {
  name       = "uptime-kuma"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "uptime-kuma"
  namespace  = "uptime-kuma"
  version    = "1.3.2"

  depends_on = [
    kubernetes_namespace.uptime-kuma
  ]

  values = [
    yamlencode({
      env = {
        TZ = "Europe/Berlin"
      }
      persistence = {
        data = {
          enabled   = true
          mountPath = "/app/data"
          accessMode = "ReadWriteOnce"
          size = "5Gi"
        }
      }
    })
  ]
}

resource "kubernetes_ingress_v1" "uptime-kuma_ingress" {
  metadata {
    name      = "uptime-kuma-ingress"
    namespace = "uptime-kuma"
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "cert-manager.io/cluster-issuer"           = "cluster-issuer-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  depends_on = [kubernetes_namespace.uptime-kuma]

  spec {
    rule {
      host = "uptime-kuma.k3s.rwxd.eu"
      http {
        path {
          backend {
            service {
              name = "uptime-kuma"
              port {
                number = 3001
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      secret_name = "uptime-kuma-tls"
      hosts = [
        "uptime-kuma.k3s.rwxd.eu"
      ]
    }
  }
}
