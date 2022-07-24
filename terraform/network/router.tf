resource "google_compute_router" "router" {
  name    = "vm-router"
  network = google_compute_network.vpc.id
  region = var.region
}

resource "google_compute_route" "egress_internet" {
  name             = "egress-internet"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc.id
  next_hop_gateway = "default-internet-gateway"
}