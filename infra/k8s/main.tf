resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = replace(var.project_name, "-", "")
  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    vnet_subnet_id  = var.subnet_id
    os_disk_size_gb = 30
    os_disk_type    = "Managed"
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }
  tags = merge(var.tags, {
    component = "kubernetes"
    lab       = "LR5"
  })
}
resource "azurerm_role_assignment" "aks_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}