locals {
  name_prefix = replace(var.project_name, "-", "")
}
data "azurerm_client_config" "current" {}
resource "azurerm_storage_account" "ml" {
  name                     = "${local.name_prefix}mlsa"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = merge(var.tags, {
    component = "ml-storage"
    lab       = "LR3"
  })
}
resource "azurerm_key_vault" "ml" {
  name                     = "${local.name_prefix}mlkv"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false
  tags = merge(var.tags, {
    component = "ml-keyvault"
    lab       = "LR3"
  })
}
resource "azurerm_application_insights" "ml" {
  name                = "ai-${var.project_name}-ml"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags = merge(var.tags, {
    component = "ml-insights"
    lab       = "LR3"
  })
}
resource "azurerm_machine_learning_workspace" "main" {
  name                    = "mlw-${var.project_name}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  storage_account_id      = azurerm_storage_account.ml.id
  key_vault_id            = azurerm_key_vault.ml.id
  application_insights_id = azurerm_application_insights.ml.id
  identity {
    type = "SystemAssigned"
  }
  tags = merge(var.tags, {
    component = "ml-workspace"
    lab       = "LR3"
  })
}