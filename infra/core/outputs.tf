output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}
output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}
output "location" {
  description = "Azure region"
  value       = azurerm_resource_group.main.location
}
output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}
output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}
output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = azurerm_subnet.app.id
}
output "k8s_subnet_id" {
  description = "ID of the Kubernetes subnet"
  value       = azurerm_subnet.k8s.id
}
output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.app.id
}