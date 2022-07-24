terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.51.0"
    }
  }
}

module "network" {
  source = "./network"
  #pass args from variables file
  region             = var.region
  management-sb-cidr = var.management-sb-cidr
  restricted-sb-cidr = var.restricted-sb-cidr
}

module "gke" {
  source = "./gke"

  project_id                 = var.project_id
  region                     = var.region
  machine_type               = var.machine_type
  node_zones                 = var.cluster_node_zones
  service_account            = var.service_account
  network_name               = module.network.vpc.name
  subnetwork                 = module.network.restricted-sn.name
  master_ipv4_cidr_block     = var.master-ip-cidr
  pods_ipv4_cidr_block       = var.pods-ip-cidr
  services_ipv4_cidr_block   = var.services-ip-cidr
  authorized_ipv4_cidr_block = "${module.bastion.ip}/32"
}


module "bastion" {
  source = "./bastion"
  #pass args from variables file
  region       = var.region
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  network_name = module.network.vpc.name
  subnetwork   = module.network.management-sn.id
}