# resource "kubernetes_namespace" "heimdall" {
#   metadata {
#     name = "heimdall"
#   }
# }
#
# resource "helm_release" "heimdall" {
#   name       = "heimdall"
#   repository = "https://k8s-at-home.com/charts/"
#   chart      = "heimdall"
#   namespace  = "heimdall"
#   version    = "8.3.2"
#
#   depends_on = [kubernetes_namespace.heimdall]
#
#   values = [
#     yamlencode({
#       env = {
#         TZ = "Europe/Berlin"
#       }
#       persistence = {
#         data = {
#           name = "heimdall"
#           enabled    = true
#           accessMode = "ReadWriteOnce"
#           size       = "5Gi"
#         }
#
#       }
#     })
#   ]
# }
#
# resource "kubernetes_ingress_v1" "heimdall_ingress" {
#   metadata {
#     name      = "heimdall-ingress"
#     namespace = "heimdall"
#     annotations = {
#       "kubernetes.io/ingress.class"              = "nginx"
#       "cert-manager.io/cluster-issuer"           = "cluster-issuer-prod"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
#     }
#   }
#
#   depends_on = [kubernetes_namespace.heimdall]
#
#   spec {
#     rule {
#       host = "heimdall.k3s.rwxd.eu"
#       http {
#         path {
#           backend {
#             service {
#               name = "heimdall"
#               port {
#                 number = 80
#               }
#             }
#           }
#           path = "/"
#         }
#
#       }
#     }
#     tls {
#       secret_name = "heimdall-tls"
#       hosts = [
#         "heimdall.k3s.rwxd.eu"
#       ]
#     }
#   }
# }
