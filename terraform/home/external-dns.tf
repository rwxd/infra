resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "external-dns"
  version    = "6.4.3"

  depends_on = [kubernetes_namespace.external-dns]

  values = [
    yamlencode({
      image = {
        registry   = "gcr.io"
        repository = "k8s-staging-external-dns/external-dns"
        tag        = "v20220128-external-dns-helm-chart-1.7.1-50-g600111f8-arm64v8"
      }
      provider = "cloudflare"
      cloudflare = {
        apiKey  = var.cloudflare_api_key
        email   = var.cloudflare_email
        proxied = false
      }
    })
  ]
}


