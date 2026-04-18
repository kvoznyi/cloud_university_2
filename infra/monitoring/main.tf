provider "kubernetes" {
  host                   = var.kube_host
  client_certificate     = var.kube_client_certificate
  client_key             = var.kube_client_key
  cluster_ca_certificate = var.kube_cluster_ca_certificate
}
provider "helm" {
  kubernetes {
    host                   = var.kube_host
    client_certificate     = var.kube_client_certificate
    client_key             = var.kube_client_key
    cluster_ca_certificate = var.kube_cluster_ca_certificate
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
    labels = {
      purpose = "observability"
      lab     = "LR5"
    }
  }
}
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.0"
  values     = [file("${path.module}/values/prometheus-stack.yaml")]
  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }
  wait            = true
  timeout         = 600
  cleanup_on_fail = true
  depends_on      = [kubernetes_namespace.monitoring]
}