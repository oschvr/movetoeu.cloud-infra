terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ovh = {
      source = "ovh/ovh"
      # ovh_cloud_project_instance and ovh_cloud_ssh_key were added after 0.50.0
      # (used by the network/kubernetes layers), so this layer pins a newer line.
      version = ">= 2.0.0, < 3.0.0"
    }
  }

  # Optional: Configure remote backend for state management
  # backend "s3" {
  #   bucket                      = "movetoeu-terraform-state"
  #   key                         = "ovh/compute/terraform.tfstate"
  #   region                      = "gra"
  #   endpoint                    = "https://s3.gra.io.cloud.ovh.net"
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  # }
}

provider "ovh" {
  endpoint           = var.ovh_endpoint
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}
