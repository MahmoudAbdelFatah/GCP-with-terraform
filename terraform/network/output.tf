output "vpc" {
  value = google_compute_network.vpc
}

output "management-sn" {
  value = google_compute_subnetwork.management-sn
}

output "restricted-sn" {
  value = google_compute_subnetwork.restricted-sn
}