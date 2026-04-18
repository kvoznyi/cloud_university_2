output "ml_workspace_id" {
  description = "ID of the Azure ML Workspace"
  value       = azurerm_machine_learning_workspace.main.id
}
output "ml_workspace_name" {
  description = "Name of the Azure ML Workspace"
  value       = azurerm_machine_learning_workspace.main.name
}
output "ml_storage_account_name" {
  description = "Name of the ML storage account"
  value       = azurerm_storage_account.ml.name
}
output "ml_key_vault_name" {
  description = "Name of the ML Key Vault"
  value       = azurerm_key_vault.ml.name
}
output "ml_app_insights_name" {
  description = "Name of Application Insights for ML"
  value       = azurerm_application_insights.ml.name
}