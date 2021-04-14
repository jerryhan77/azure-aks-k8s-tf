# Initialize Helm
provider "helm" {
  kubernetes {
    host                   = module.aks_cluster.kube_config.0.host
    client_certificate     = base64decode(module.aks_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(module.aks_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(module.aks_cluster.kube_config.0.cluster_ca_certificate)
  }
}

# Initialize kubernetes
provider "kubernetes" {
  host                   = module.aks_cluster.kube_config.0.host
  client_certificate     = base64decode(module.aks_cluster.kube_config.0.client_certificate)
  client_key             = base64decode(module.aks_cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(module.aks_cluster.kube_config.0.cluster_ca_certificate)
}

# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx" {
  name       = "nginx-ingress"
  #repository = data.helm_repository.stable.url
  #repository = data.helm_repository.stable.metadata.0.name
  chart      = "ingress-nginx/ingress-nginx"
  namespace = var.ingress_namespace

  set {
    name  = "controller.replicaCount"
    value = 2
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/azure-dns-label-name\""
    value = var.domain_name_label
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.ingress_lb.ip_address
  }
  depends_on = [ kubernetes_namespace.ingress ]
}

# cert-manager
resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "jetstack/cert-manager"
  namespace = var.ingress_namespace
  timeout   = 1800
  depends_on = [ helm_release.nginx ]

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# letsencrypt
resource "helm_release" "letsencrypt" {
  name      = "letsencrypt"
  chart     = "${path.root}/charts/letsencrypt/"
  namespace = var.ingress_namespace
  timeout   = 1800
  depends_on = [ helm_release.cert-manager ]
}

resource "kubernetes_namespace" "ingress" {
  metadata {

    labels = {
      "cert-manager.io/disable-validation" = "true"
    }

    name = var.ingress_namespace
  }
  depends_on = [ module.aks_cluster ]
}
