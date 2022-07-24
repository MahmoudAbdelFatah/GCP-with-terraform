resource "google_container_cluster" "private_cluster" {
  name     = "private-cluster"
  location = var.region
  network = var.network_name
  subnetwork = var.subnetwork
  # We can't create a cluster with no node pool defined, So we create the smallest possible default.
  remove_default_node_pool = true
  initial_node_count       = 1

  logging_service = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

 
  ip_allocation_policy {
    cluster_ipv4_cidr_block = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  master_auth {

	  client_certificate_config {
      issue_client_certificate = false
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.authorized_ipv4_cidr_block != null ? [var.authorized_ipv4_cidr_block] : []
    content {
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value
        display_name = "External Control Plane access"
      }
    }
  }

  private_cluster_config {
    # to can connect to the cluster from the pasition vm
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  release_channel {
	  channel = "STABLE"
  }

  addons_config {
    // Enable network policy (Calico)
    network_policy_config {
        disabled = false
      }
  }
  network_policy {
    enabled = "true"
  }

}

resource "google_container_node_pool" "private-cluster-node-pool" {
  name           = "private-cluster-node-pool"
  location       = google_container_cluster.private_cluster.location
  node_locations = var.node_zones
  cluster        = google_container_cluster.private_cluster.name
  node_count     = 1

  autoscaling {
    max_node_count = 1
    min_node_count = 1
  }
  max_pods_per_node = 100

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    # To use cheaper VMs for kubernetes nodes
    preemptible  = true
    machine_type = var.machine_type

    service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      cluster = google_container_cluster.private_cluster.name
    }
  }
}
