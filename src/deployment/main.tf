# Cluster Resource Group

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_dns_zone" "azure-liandisys" {
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_dns_a_record" "ingress" {
  name                = "*"
  zone_name           = azurerm_dns_zone.azure-liandisys.name
  resource_group_name = azurerm_resource_group.aks.name
  ttl                 = 300
  #records             = ["20.44.139.163"]
  records             = [ azurerm_public_ip.ingress_lb.ip_address ]
}

resource "azurerm_public_ip" "ingress_lb" {
  name                = "ingress_lb_ip"
  resource_group_name = module.aks_cluster.azurerm_kubernetes_cluster_node_resource_group
  location            = azurerm_resource_group.aks.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "azure-ingress"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_container_registry" "acr" {
  name                     = "liandisys"
  resource_group_name      = azurerm_resource_group.aks.name
  location                 = azurerm_resource_group.aks.location
  sku                      = "Premium"
  admin_enabled            = false

  network_rule_set {
    default_action = "Deny"
    virtual_network {
      action = "Allow"
      subnet_id = module.aks_network.aks_subnet_id
    }

    ip_rule = [
      for ip_range in var.acr_ip_ranges : {
        action   = "Allow"
        ip_range = ip_range
      }
    ]
  }
}

# AKS Cluster Network

module "aks_network" {
  source              = "../modules/aks_network"
  subnet_name         = var.subnet_name
  vnet_name           = var.vnet_name
  resource_group_name = azurerm_resource_group.aks.name
  subnet_cidr         = var.subnet_cidr
  location            = var.location
  address_space       = var.address_space
}

# AKS IDs

module "aks_identities" {
  source       = "../modules/aks_identities"
  cluster_name = var.cluster_name
}

# AKS Log Analytics

module "log_analytics" {
  source                           = "../modules/log_analytics"
  resource_group_name              = azurerm_resource_group.aks.name
  log_analytics_workspace_location = var.log_analytics_workspace_location
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_sku      = var.log_analytics_workspace_sku
}


# AKS Cluster

module "aks_cluster" {
  source                   = "../modules/aks-cluster"
  cluster_name             = var.cluster_name
  location                 = var.location
  dns_prefix               = var.dns_prefix
  resource_group_name      = azurerm_resource_group.aks.name
  kubernetes_version       = var.kubernetes_version
  node_count               = var.node_count
  min_count                = var.min_count
  max_count                = var.max_count
  os_disk_size_gb          = "1028"
  max_pods                 = "110"
  vm_size                  = var.vm_size
  vnet_subnet_id           = module.aks_network.aks_subnet_id
  client_id                = module.aks_identities.cluster_client_id
  client_secret            = module.aks_identities.cluster_sp_secret
  diagnostics_workspace_id = module.log_analytics.azurerm_log_analytics_workspace
  availability_zones       = var.availability_zones
  api_ip_ranges            = var.api_ip_ranges
}







