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
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}
variable "node_count" {
  description = "Number of nodes in the default pool"
  type        = number
  default     = 1
}
variable "vm_size" {
  description = "VM size for the node pool"
  type        = string
  default     = "Standard_D2s_v3"
}
variable "subnet_id" {
  description = "Subnet ID for the AKS cluster"
  type        = string
  default     = null
}
variable "acr_id" {
  description = "ID of the ACR to attach for image pulls"
  type        = string
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
variable "service_cidr" {
  description = "The Network Range used by the Kubernetes service"
  type        = string
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery"
  type        = string
}
