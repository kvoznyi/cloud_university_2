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
  description = "Project name for resource naming"
  type        = string
  default     = "workout-planner"
}
variable "sku" {
  description = "ACR SKU tier (Basic is cheapest)"
  type        = string
  default     = "Basic"
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}