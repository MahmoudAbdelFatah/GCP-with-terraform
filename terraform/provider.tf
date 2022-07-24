provider "google" {
  credentials = file(var.credentials_file_path)
  project     = "gcp-terraform-357100"
  region      = "us-central1"
  zone        = var.zone
}