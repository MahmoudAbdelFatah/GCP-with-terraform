resource "google_compute_subnetwork" "management-sn" {
  name          = "management-subnet"
  ip_cidr_range = var.management-sb-cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  # When enabled, VMs in this subnetwork without external IP addresses 
  # can access Google APIs and services by using Private Google Access.
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "restricted-sn" {
  name          = "restricted-subnet"
  ip_cidr_range = var.restricted-sb-cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  # When enabled, VMs in this subnetwork without external IP addresses 
  # can access Google APIs and services by using Private Google Access.
  private_ip_google_access = true
}