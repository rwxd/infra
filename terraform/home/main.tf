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

resource "kubernetes_namespace" "whoami" {
  metadata {
    name = "whoami"
  }
}

resource "helm_release" "whoami" {
  name       = "whoami"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "whoami"
  namespace  = "whoami"

  depends_on = [
    helm_release.nginx-ingress-controller,
    kubernetes_namespace.whoami
  ]

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "whoami.k3s.rwxd.eu"
  }

  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
      name = "ingress.annotations.cert-manager\\.io/cluster-issuer"
      value = "cluster-issuer-prod"
  }

  set {
      name = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
      value = "true"
      type = "string"
  }

  set {
      name = "ingress.tls[0].secretName"
      value = "whoami-tls"
  }

  set {
      name = "ingress.tls[0].hosts[0]"
      value = "whoami.k3s.rwxd.eu"
  }
}

resource "kubernetes_namespace" "whoami2" {
  metadata {
    name = "whoami2"
  }
}


resource "helm_release" "whoami2" {
  name       = "whoami2"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "whoami"
  namespace  = "whoami2"

  depends_on = [
    helm_release.nginx-ingress-controller,
    kubernetes_namespace.whoami2
  ]

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "whoami2.k3s.rwxd.eu"
  }

  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
      name = "ingress.annotations.cert-manager\\.io/cluster-issuer"
      value = "cluster-issuer-prod"
  }

  set {
      name = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
      value = "true"
      type = "string"
  }

  set {
      name = "ingress.tls[0].secretName"
      value = "whoami2-tls"
  }

  set {
      name = "ingress.tls[0].hosts[0]"
      value = "whoami2.k3s.rwxd.eu"
  }
}
