output "grafana_service_name" {
  description = "Grafana service name for port-forwarding"
  value       = "kube-prometheus-stack-grafana"
}
output "prometheus_service_name" {
  description = "Prometheus service name for port-forwarding"
  value       = "kube-prometheus-stack-prometheus"
}
output "grafana_port_forward_command" {
  description = "Command to port-forward Grafana dashboard"
  value       = "kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n ${var.monitoring_namespace}"
}
output "prometheus_port_forward_command" {
  description = "Command to port-forward Prometheus UI"
  value       = "kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n ${var.monitoring_namespace}"
}