resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"

  depends_on = [
    kubernetes_namespace.cert-manager
  ]

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "kubernetes_secret" "cert-manager-cloudflare-api" {
  metadata {
    name      = "cert-manager-cloudflare-api"
    namespace = "cert-manager"
  }

  data = {
    api_key = var.cloudflare_api_key
  }
}

resource "kubectl_manifest" "cluster-issuer-prod" {
  depends_on = [
    helm_release.cert-manager,
    kubernetes_secret.cert-manager-cloudflare-api
  ]

  yaml_body = <<YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: "cluster-issuer-prod"
      namespace: "cert-manager"
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: "cluster-issuer-prod-private-key"
        solvers:
          - dns01:
              cloudflare:
                email: ${var.cloudflare_email}
                apiKeySecretRef:
                  name: "cert-manager-cloudflare-api"
                  key: "api_key"
  YAML
}