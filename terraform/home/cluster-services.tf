resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = "metallb"
  version    = "0.12.1"

  depends_on = [kubernetes_namespace.metallb]

  values = [
    yamlencode({
      configInline = {
        address-pools = [
          {
            name     = "default"
            protocol = "layer2"
            addresses = [
              "192.168.3.200-192.168.3.250"
            ]
          }
        ]
      }
    })
  ]
}

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
  version    = "4.1.1"

  depends_on = [helm_release.metallb, kubernetes_namespace.nginx-ingress-controller]

  values = [
    yamlencode({
      defaultBackend = {
        enabled = false
      }
    })
  ]
}

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
  version    = "v1.8.0"

  depends_on = [kubernetes_namespace.cert-manager]

  values = [
    yamlencode({
      installCRDs = true
    })
  ]
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
  depends_on = [helm_release.cert-manager, kubernetes_secret.cert-manager-cloudflare-api]

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
