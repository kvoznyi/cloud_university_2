variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "workout-planner"
}
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "West Europe"
}
variable "environment" {
  description = "Environment tag (dev, staging, prod)"
  type        = string
  default     = "dev"
}
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "app_subnet_prefixes" {
  description = "Address prefixes for the app subnet"
  type        = list(string)
}

variable "k8s_subnet_prefixes" {
  description = "Address prefixes for the k8s subnet"
  type        = list(string)
}
