variable "kube_config_raw" {
  description = "Raw kubeconfig from AKS cluster output"
  type        = string
  sensitive   = true
}
variable "kube_host" {
  description = "Kubernetes API server host"
  type        = string
  sensitive   = true
}
variable "kube_client_certificate" {
  description = "Client certificate for K8s auth"
  type        = string
  sensitive   = true
}
variable "kube_client_key" {
  description = "Client key for K8s auth"
  type        = string
  sensitive   = true
}
variable "kube_cluster_ca_certificate" {
  description = "Cluster CA certificate"
  type        = string
  sensitive   = true
}
variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "WorkoutPlanner2026!"
  sensitive   = true
}
variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring"
  type        = string
  default     = "monitoring"
}