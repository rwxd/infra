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
  version    = "0.13.4"

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
