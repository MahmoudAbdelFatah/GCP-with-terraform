resource "google_service_account" "bastion-sa" {
  account_id   = "bastion-service-account"
  display_name = "Service Account for Bastion VM"
}



