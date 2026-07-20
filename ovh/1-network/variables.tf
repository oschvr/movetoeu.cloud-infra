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
  description = "OVH region for the network"
  type        = string
  default     = "GRA11"

  validation {
    condition     = can(regex("^(GRA|SBG|RBX|WAW|DE|UK|BHS)[0-9]*$", var.region))
    error_message = "Region must be a valid OVH region code (e.g., GRA11, SBG5, WAW1)"
  }
}

variable "network_name" {
  description = "Name of the private network"
  type        = string
  default     = "k8s-private-network"
}

variable "vlan_id" {
  description = "VLAN ID for the private network (0-4000)"
  type        = number
  default     = 0

  validation {
    condition     = var.vlan_id >= 0 && var.vlan_id <= 4000
    error_message = "VLAN ID must be between 0 and 4000"
  }
}

variable "nodes_subnet_cidr" {
  description = "CIDR block for Kubernetes nodes subnet"
  type        = string
  default     = "192.168.0.0/24"
}

variable "nodes_subnet_start" {
  description = "Start IP address for nodes subnet DHCP range"
  type        = string
  default     = "192.168.0.10"
}

variable "nodes_subnet_end" {
  description = "End IP address for nodes subnet DHCP range"
  type        = string
  default     = "192.168.0.250"
}

variable "lb_subnet_cidr" {
  description = "CIDR block for load balancers subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "lb_subnet_start" {
  description = "Start IP address for load balancers subnet DHCP range"
  type        = string
  default     = "192.168.1.10"
}

variable "lb_subnet_end" {
  description = "End IP address for load balancers subnet DHCP range"
  type        = string
  default     = "192.168.1.250"
}
