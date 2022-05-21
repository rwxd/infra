# infrastructure

## What do we have here?

Ansible Roles & Playbooks to configure Pi's with a default configuration, hardening, Wireguard,
Cloudflare Dynamic DNS, Docker & K3s.

### K3s

Some Pi's participate in a K3s cluster. The cluster is managed with Terraform.
All nodes have hard drive for replicated persistent storage with [Longhorn](https://longhorn.io/).

Bare metal load-balancing works thanks to [MetalLB](https://metallb.universe.tf/).
Ingress is managed with the [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/).
DNS Entries are created with [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) and
the Let's Encrypt TLS certificates are generated with [cert-manager](https://cert-manager.io/docs/).
