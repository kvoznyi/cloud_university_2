locals {
  acr_name = replace("acr${var.project_name}", "-", "")
}
resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true
  tags = merge(var.tags, {
    component = "registry"
  })
}