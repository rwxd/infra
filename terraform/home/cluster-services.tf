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

  depends_on = [kubernetes_namespace.metallb, ]

  set {
    name  = "configInline.address-pools[0].name"
    value = "default"
    type  = "string"
  }

  set {
    name  = "configInline.address-pools[0].protocol"
    value = "layer2"
    type  = "string"
  }

  set {
    name  = "configInline.address-pools[0].addresses[0]"
    value = "192.168.3.200-192.168.3.250"
    type  = "string"
  }
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

  set {
    name  = "defaultBackend.enabled"
    value = false
  }
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
  version    = "6.4.2"

  depends_on = [
    kubernetes_namespace.external-dns,
  ]

  set {
    name  = "image.registry"
    value = "gcr.io"
    type  = "string"
  }

  set {
    name  = "image.repository"
    value = "k8s-staging-external-dns/external-dns"
    type  = "string"
  }

  set {
    name  = "image.tag"
    value = "v20220128-external-dns-helm-chart-1.7.1-50-g600111f8-arm64v8"
    type  = "string"
  }

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set {
    name  = "cloudflare.apiKey"
    value = var.cloudflare_api_key
  }

  set {
    name  = "cloudflare.email"
    value = var.cloudflare_email
  }

  set {
    name  = "cloudflare.proxied"
    value = false
  }
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
