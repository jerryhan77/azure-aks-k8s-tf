output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "kubernetes_cluster_name" {
  value = module.aks_cluster.azurerm_kubernetes_cluster_name
}

output "azurerm_kubernetes_cluster_ingress_lb_ip" {
  value = azurerm_public_ip.ingress_lb.ip_address
}
