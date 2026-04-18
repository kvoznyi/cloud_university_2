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
variable "subnet_id" {
  description = "ID of the subnet to deploy the VM into"
  type        = string
}
variable "vm_size" {
  description = "VM size (Standard_D2s_v3 used due to capacity limits on B-series)"
  type        = string
  default     = "Standard_D2s_v3"
}
variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}
variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
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
variable "docker_image" {
  description = "Docker image name (without registry prefix)"
  type        = string
  default     = "workoutplanner:latest"
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}