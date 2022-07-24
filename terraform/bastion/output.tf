output "ip" {
  value       = google_compute_instance.bastion.network_interface.0.network_ip
  description = "The IP address of the Bastion instance."
}

output "ssh" {
  description = "gcloud ssh command to bastion vm"
  value       = "gcloud compute ssh ${google_compute_instance.bastion.name} --project ${var.project_id} --zone ${google_compute_instance.bastion.zone} -- -L8888:127.0.0.1:8888"
}