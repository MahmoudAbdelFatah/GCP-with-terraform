variable "region" {}
variable "project_id" {}
variable "zone" {}
variable "cluster_node_zones" {}

variable "credentials_file_path" {}
variable "service_account" {}

variable "machine_type" {}
variable "management-sb-cidr" {}
variable "restricted-sb-cidr" {}

variable "master-ip-cidr" {}   //10.100.100.0/28
variable "pods-ip-cidr" {}     //10.101.0.0/16
variable "services-ip-cidr" {} //10.102.0.0/16