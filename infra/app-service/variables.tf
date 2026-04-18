variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}
variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "workout-planner"
}
variable "acr_login_server" {
  description = "ACR login server URL"
  type        = string
}
variable "acr_username" {
  description = "ACR admin username"
  type        = string
  sensitive   = true
}
variable "acr_password" {
  description = "ACR admin password"
  type        = string
  sensitive   = true
}
variable "docker_image_name" {
  description = "Docker image name in ACR"
  type        = string
  default     = "workoutplanner"
}
variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
variable "sku_name" {
  description = "App Service Plan SKU (B1 = basic, F1 = free)"
  type        = string
  default     = "B1"
}
variable "ml_api_url" {
  description = "URL of the ML prediction API"
  type        = string
  default     = "http://localhost:5000"
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}