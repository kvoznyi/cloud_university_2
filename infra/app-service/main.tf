resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags = merge(var.tags, {
    component = "app-service"
    lab       = "LR4"
  })
}
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  site_config {
    always_on = var.sku_name != "F1"
    application_stack {
      docker_registry_url      = "https://${var.acr_login_server}"
      docker_registry_username = var.acr_username
      docker_registry_password = var.acr_password
      docker_image_name        = "${var.docker_image_name}:${var.docker_image_tag}"
    }
  }
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${var.acr_login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = var.acr_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.acr_password
    "MlApi__BaseUrl"                      = var.ml_api_url
    "ASPNETCORE_ENVIRONMENT"              = "Production"
  }
  https_only = true
  identity {
    type = "SystemAssigned"
  }
  tags = merge(var.tags, {
    component = "app-service"
    lab       = "LR4"
  })
}