variable "project_id" {}

variable "region" {}
variable "node_zones" {
  type = list(string)
}
variable "machine_type" {}
variable "network_name" {}
variable "subnetwork" {}
variable "service_account" {}
variable "master_ipv4_cidr_block" {}
variable "pods_ipv4_cidr_block" {}
variable "services_ipv4_cidr_block" {}
variable "authorized_ipv4_cidr_block" {
  default = null
}
