# Look up the flavor (instance type) by name for the target region
data "ovh_cloud_project_flavors" "available" {
  service_name = var.ovh_project_id
  region       = var.region
  name_filter  = var.flavor_name
}

# Look up available OS images for the target region, filtered client-side by name
data "ovh_cloud_project_images" "available" {
  service_name = var.ovh_project_id
  region       = var.region
  os_type      = var.image_os_type
}

locals {
  matching_flavors = tolist(data.ovh_cloud_project_flavors.available.flavors)
  matching_images = [
    for image in data.ovh_cloud_project_images.available.images : image
    if image.name == var.image_name
  ]
}

# Register the existing local SSH key so it can be attached to the instance
resource "ovh_cloud_ssh_key" "compute_key" {
  service_name = var.ovh_project_id
  name         = var.ssh_key_name
  public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
}


# Standalone compute instance
resource "ovh_cloud_project_instance" "compute" {
  service_name   = var.ovh_project_id
  region         = var.region
  billing_period = var.billing_period
  name           = var.instance_name

  boot_from {
    image_id = try(local.matching_images[0].id, "")
  }

  flavor {
    flavor_id = try(local.matching_flavors[0].id, "")
  }

  ssh_key {
    name = var.ssh_key_name
  }

  dynamic "network" {
    for_each = (var.enable_public_ip || var.enable_private_network) ? [1] : []
    content {
      public = var.enable_public_ip

      dynamic "private" {
        for_each = var.enable_private_network ? [1] : []
        content {
          network {
            id        = var.private_network_id
            subnet_id = var.private_network_subnet_id != "" ? var.private_network_subnet_id : null
          }
          ip = var.private_ip != "" ? var.private_ip : null
        }
      }
    }
  }

  user_data = var.user_data != "" ? var.user_data : null

  lifecycle {
    precondition {
      condition     = var.enable_public_ip || var.enable_private_network
      error_message = "At least one of enable_public_ip or enable_private_network must be true."
    }
    precondition {
      condition     = !var.enable_private_network || var.private_network_id != ""
      error_message = "private_network_id must be set (from the 1-network workspace output) when enable_private_network is true."
    }
    precondition {
      condition     = length(local.matching_flavors) > 0
      error_message = "No flavor named '${var.flavor_name}' found in region ${var.region}."
    }
    precondition {
      condition     = length(local.matching_images) > 0
      error_message = "No image named '${var.image_name}' found in region ${var.region}."
    }
  }
}
