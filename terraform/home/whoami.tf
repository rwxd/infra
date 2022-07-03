# resource "kubernetes_namespace" "whoami" {
#   metadata {
#     name = "whoami"
#   }
# }
#
# resource "helm_release" "whoami" {
#   name       = "whoami"
#   repository = "https://cowboysysop.github.io/charts/"
#   chart      = "whoami"
#   namespace  = "whoami"
#   version    = "2.5.5"
#
#   depends_on = [
#     kubernetes_namespace.whoami
#   ]
#
#   values = [
#     yamlencode({
#       ingress = {
#         enabled = true
#         hosts = [
#           {
#             host = "whoami.k3s.rwxd.eu"
#             paths = [
#               "/"
#             ]
#           }
#         ]
#         tls = [
#           {
#             secretName = "whoami-tls"
#             hosts = [
#               "whoami.k3s.rwxd.eu"
#             ]
#           }
#         ]
#         annotations = {
#           "kubernetes.io/ingress.class"              = "nginx"
#           "cert-manager.io/cluster-issuer"           = "cluster-issuer-prod"
#           "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
#         }
#       }
#     })
#   ]
# }
