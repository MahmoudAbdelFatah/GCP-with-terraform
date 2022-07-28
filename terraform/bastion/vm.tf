resource "google_compute_instance" "bastion" {
  name         = "management-vm"
  machine_type = var.machine_type
  zone         = var.zone
  project = var.project_id
  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  service_account {
    email  = google_service_account.bastion-sa.email
    scopes = ["cloud-platform"]
  }

  tags         = ["bastion"]
}