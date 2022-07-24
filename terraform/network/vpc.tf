resource "google_compute_network" "vpc" {
  name                    = "vpc-gke"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
  delete_default_routes_on_create = true
}