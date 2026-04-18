output "acr_id" {
  description = "ID of the Container Registry"
  value       = azurerm_container_registry.main.id
}
output "acr_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.main.name
}
output "acr_login_server" {
  description = "Login server URL for the Container Registry"
  value       = azurerm_container_registry.main.login_server
}
output "acr_admin_username" {
  description = "Admin username for the Container Registry"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}
output "acr_admin_password" {
  description = "Admin password for the Container Registry"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}