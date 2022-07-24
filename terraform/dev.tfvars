region     = "us-central1"
zone       = "us-central1-a"
project_id = "gcp-terraform-357100"

credentials_file_path = "./service-account-credentials.json"
service_account       = "my-sa-817@gcp-terraform-357100.iam.gserviceaccount.com"
cluster_node_zones    = ["us-central1-b"]


machine_type       = "e2-medium"
management-sb-cidr = "10.0.0.0/16"
restricted-sb-cidr = "10.10.0.0/16"

master-ip-cidr   = "10.100.100.0/28"
pods-ip-cidr     = "10.101.0.0/16"
services-ip-cidr = "10.102.0.0/16"