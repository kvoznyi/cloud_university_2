output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.app.ip_address
}
output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.app.id
}
output "app_url" {
  description = "URL of the deployed application"
  value       = "http://${azurerm_public_ip.app.ip_address}"
}