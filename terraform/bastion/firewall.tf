// Allow access to the Bastion Host via SSH.
resource "google_compute_firewall" "bastion-ssh" {
  name          = "bastion-ssh"
  network       = var.network_name
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  project = var.project_id 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  target_tags = ["bastion"]
}
