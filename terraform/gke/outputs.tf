output "name" {
  value = google_container_cluster.private_cluster.name
  description = "The Kubernetes cluster name."
}