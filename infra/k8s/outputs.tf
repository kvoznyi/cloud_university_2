output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}
output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}
output "kube_config_raw" {
  description = "Raw kubeconfig for the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}
output "host" {
  description = "Kubernetes API server host"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive   = true
}
output "client_certificate" {
  description = "Client certificate for authentication"
  value       = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  sensitive   = true
}
output "client_key" {
  description = "Client key for authentication"
  value       = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  sensitive   = true
}
output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}
output "get_credentials_command" {
  description = "Azure CLI command to get kubeconfig"
  value       = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${azurerm_kubernetes_cluster.main.name}"
}