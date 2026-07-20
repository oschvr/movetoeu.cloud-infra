terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.50.0"
    }
  }

  # Optional: Configure remote backend for state management
  # Uncomment and configure based on your requirements
  # backend "s3" {
  #   bucket                      = "movetoeu-terraform-state"
  #   key                         = "ovh/common/terraform.tfstate"
  #   region                      = "gra"
  #   endpoint                    = "https://s3.gra.io.cloud.ovh.net"
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  # }
}

provider "ovh" {
  endpoint = var.ovh_endpoint

  # Credentials can be provided via variables or environment variables
  # Environment variables: OVH_APPLICATION_KEY, OVH_APPLICATION_SECRET, OVH_CONSUMER_KEY
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}
