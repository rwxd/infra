resource "kubernetes_namespace" "homer" {
  metadata {
    name = "homer"
  }
}

resource "helm_release" "homer" {
  name       = "homer"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "homer"
  namespace  = "homer"
  version    = "7.2.2"

  depends_on = [kubernetes_namespace.homer]

  values = [
    yamlencode({
      env = {
        TZ = "Europe/Berlin"
      }
      configmap = {
        config = {
          enabled = true
          data = {
            "config.yml" = <<YAML
              # Homepage configuration
              # See https://fontawesome.com/v5/search for icons options

              title: "Dashboard"
              subtitle: "Homer" # documentTitle: "Welcome" # Customize the browser tab text
              icon: "fas fa-burger-soda"

              header: true # Set to false to hide the header
              # Optional: Different hotkey for search, defaults to "/"
              # hotkey:
              #   search: "Shift"
              footer: '<p>Created with <span class="has-text-danger">❤️</span> with <a href="https://bulma.io/">bulma</a>, <a href="https://vuejs.org/">vuejs</a> & <a href="https://fontawesome.com/">font awesome</a> // Fork me on <a href="https://github.com/bastienwirtz/homer"><i class="fab fa-github-alt"></i></a></p>' # set false if you want to hide it.

              columns: "3" # "auto" or number (must be a factor of 12: 1, 2, 3, 4, 6, 12)
              connectivityCheck: true # whether you want to display a message when the apps are not accessible anymore (VPN disconnected for example)

              # Set the default layout and color scheme
              defaults:
                layout: columns # Either 'columns', or 'list'
                colorTheme: auto # One of 'auto', 'light', or 'dark'

              # Optional theming
              theme: default # 'default' or one of the themes available in 'src/assets/themes'.

              # Here is the exhaustive list of customization parameters
              # However all value are optional and will fallback to default if not set.
              # if you want to change only some of the colors, feel free to remove all unused key.
              colors:
                light:
                  highlight-primary: "#3367d6"
                  highlight-secondary: "#4285f4"
                  highlight-hover: "#5a95f5"
                  background: "#f5f5f5"
                  card-background: "#ffffff"
                  text: "#363636"
                  text-header: "#424242"
                  text-title: "#303030"
                  text-subtitle: "#424242"
                  card-shadow: rgba(0, 0, 0, 0.1)
                  link: "#3273dc"
                  link-hover: "#363636"
                  background-image: "assets/your/light/bg.png"
                dark:
                  highlight-primary: "#3367d6"
                  highlight-secondary: "#4285f4"
                  highlight-hover: "#5a95f5"
                  background: "#131313"
                  card-background: "#2b2b2b"
                  text: "#eaeaea"
                  text-header: "#ffffff"
                  text-title: "#fafafa"
                  text-subtitle: "#f5f5f5"
                  card-shadow: rgba(0, 0, 0, 0.4)
                  link: "#3273dc"
                  link-hover: "#ffdd57"
                  background-image: "assets/your/dark/bg.png"

              # Services
              # First level array represents a group.
              # Leave only a "items" key if not using group (group name, icon & tagstyle are optional, section separation will not be displayed).
              services:
                - name: "Applications"
                  icon: "fas fa-code-branch"
                  # A path to an image can also be provided. Note that icon take precedence if both icon and logo are set.
                  # logo: "path/to/logo"
                  items:
                    - name: "NextCloud"
                      icon: "fas fa-cloud"
                      subtitle: "Self-hosted Cloud"
                      url: "https://cloud.fritz.box/"
                      target: "_blank" # optional html tag target attribute
                    - name: "SmartHome"
                      icon: "fas fa-house-signal"
                      subtitle: "Z-Wave"
                      url: "???"
                      target: "_blank" # optional html tag target attribute
                    - name: "whoami"
                      icon: "fas fa-browser"
                      subtitle: "HTTP Debuging"
                      url: "https://whoami.k3s.rwxd.eu"
                      target: "_blank" # optional html tag target attribute
                - name: "Monitoring"
                  icon: "fas fa-heartbeat"
                  items: []
            YAML
          }
        }
      }
    })
  ]
}

resource "kubernetes_ingress_v1" "homer_ingress" {
  metadata {
    name      = "homer-ingress"
    namespace = "homer"
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "cert-manager.io/cluster-issuer"           = "cluster-issuer-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  depends_on = [kubernetes_namespace.homer]

  spec {
    rule {
      host = "homer.k3s.rwxd.eu"
      http {
        path {
          backend {
            service {
              name = "homer"
              port {
                number = 8080
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      secret_name = "homer-tls"
      hosts = [
        "homer.k3s.rwxd.eu"
      ]
    }
  }
}
