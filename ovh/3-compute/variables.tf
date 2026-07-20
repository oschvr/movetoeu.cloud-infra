variable "ovh_endpoint" {
  description = "OVH API endpoint"
  type        = string
  default     = "ovh-eu"
}

variable "ovh_application_key" {
  description = "OVH API application key"
  type        = string
  sensitive   = true
}

variable "ovh_application_secret" {
  description = "OVH API application secret"
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH API consumer key"
  type        = string
  sensitive   = true
}

variable "ovh_project_id" {
  description = "OVH Public Cloud project ID"
  type        = string
}

variable "region" {
  description = "OVH region for the instance (must match the region used by the network workspace to attach to the private network)"
  type        = string
  default     = "DE1"

  validation {
    condition     = can(regex("^(GRA|SBG|RBX|WAW|DE|UK|BHS)[0-9]*$", var.region))
    error_message = "Region must be a valid OVH region code (e.g., GRA11, SBG5, WAW1)"
  }
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "movetoeucloud-compute"
}

variable "billing_period" {
  description = "Instance billing period"
  type        = string
  default     = "hourly"

  validation {
    condition     = contains(["hourly", "monthly"], var.billing_period)
    error_message = "Billing period must be either hourly or monthly"
  }
}

variable "flavor_name" {
  description = "Flavor (instance type) name, e.g. d2-2, b2-7, b3-8. See https://www.ovhcloud.com/en/public-cloud/prices/"
  type        = string
  default     = "d2-2"
}

variable "image_name" {
  description = "Name of the OS image to boot from, as listed by the ovh_cloud_project_images data source for the target region"
  type        = string
  default     = "Ubuntu 24.04"
}

variable "image_os_type" {
  description = "OS family used to filter available images (linux, windows, bsd, baremetal-linux)"
  type        = string
  default     = "linux"
}

variable "ssh_key_name" {
  description = "Name to register the SSH key under in the OVH project"
  type        = string
  default     = "movetoeucloud-key"
}

variable "ssh_public_key_path" {
  description = "Path to the local SSH public key file to register and attach to the instance"
  type        = string
  default     = "~/.ssh/movetoeu.cloud.pub"
}

variable "enable_public_ip" {
  description = "Attach a public network interface so the instance is directly reachable from the internet"
  type        = bool
  default     = true
}

variable "enable_private_network" {
  description = "Attach the instance to the existing private network from the network workspace"
  type        = bool
  default     = true
}

variable "private_network_id" {
  description = "OpenStack ID of the private network to attach to (from the network workspace output: private_network_openstack_id)"
  type        = string
  default     = ""
}

variable "private_network_subnet_id" {
  description = "ID of the subnet to attach to within the private network (from the network workspace output, e.g. nodes_subnet_id)"
  type        = string
  default     = ""
}

variable "private_ip" {
  description = "Static IP to request in the private subnet. Leave empty to let DHCP assign one"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Cloud-init / user-data script to run on first boot. Leave empty to skip"
  type        = string
  default     = ""
}
