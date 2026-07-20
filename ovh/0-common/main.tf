# This workspace primarily configures the provider and validates access
# The OVH Public Cloud project should already exist

# Data source to validate project access
data "ovh_cloud_project" "project" {
  service_name = var.ovh_project_id
}

# Local values for use across workspaces
locals {
  project_id = var.ovh_project_id
  tags = {
    managed_by = "terraform"
    project    = "movetoeu.cloud"
  }
}

# Data source to get the regions with the network service up
data "ovh_cloud_project_regions" "regions" {
  service_name    = var.ovh_project_id
  has_services_up = ["network","instance"]
}
