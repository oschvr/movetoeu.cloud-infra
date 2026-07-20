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
  description = "OVH region for the Kubernetes cluster (must match network region)"
  type        = string
  default     = "DE1"

  validation {
    condition     = can(regex("^(GRA|SBG|RBX|WAW|DE|UK|BHS)[0-9]*$", var.region))
    error_message = "Region must be a valid OVH region code (e.g., GRA11, SBG5, WAW1)"
  }
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "k8s-cluster"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g., '1.28', '1.29'). Leave empty for latest available version"
  type        = string
  default     = ""
}

variable "update_policy" {
  description = "Cluster update policy: ALWAYS_UPDATE, MINIMAL_DOWNTIME, or NEVER_UPDATE"
  type        = string
  default     = "MINIMAL_DOWNTIME"

  validation {
    condition     = contains(["ALWAYS_UPDATE", "MINIMAL_DOWNTIME", "NEVER_UPDATE"], var.update_policy)
    error_message = "Update policy must be one of: ALWAYS_UPDATE, MINIMAL_DOWNTIME, NEVER_UPDATE"
  }
}

variable "private_network_id" {
  description = "OpenStack ID of the private network (from network workspace output)"
  type        = string
}

variable "nodes_subnet_id" {
  description = "ID of the subnet for Kubernetes nodes (from network workspace output)"
  type        = string
}

variable "lb_subnet_id" {
  description = "ID of the subnet for load balancers (from network workspace output)"
  type        = string
}

variable "private_network_routing_as_default" {
  description = "Use private network as default route"
  type        = bool
  default     = true
}

variable "default_vrack_gateway" {
  description = "Default gateway IP for vRack (leave empty for automatic)"
  type        = string
  default     = ""
}

variable "kube_proxy_mode" {
  description = "Kube-proxy mode: iptables or ipvs"
  type        = string
  default     = "iptables"

  validation {
    condition     = contains(["iptables", "ipvs"], var.kube_proxy_mode)
    error_message = "Kube-proxy mode must be either iptables or ipvs"
  }
}

variable "node_pools" {
  description = "Map of node pools to create"
  type = map(object({
    flavor_name   = string           # Instance type (e.g., b2-7, c2-15, r2-30)
    desired_nodes = number           # Initial number of nodes
    min_nodes     = optional(number, 1)     # Minimum nodes (for autoscaling)
    max_nodes     = optional(number, 10)    # Maximum nodes (for autoscaling)
    autoscale     = optional(bool, false)   # Enable autoscaling
    monthly_billed = optional(bool, false)  # Use monthly billing for ~30% discount
    anti_affinity = optional(bool, false)   # Enable anti-affinity
  }))

  default = {
    "default-pool" = {
      flavor_name   = "d2-8"
      desired_nodes = 3
      min_nodes     = 1
      max_nodes     = 5
      autoscale     = true
      monthly_billed = false
      anti_affinity = false
    }
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools : v.min_nodes >= 0 && v.max_nodes >= v.min_nodes && v.desired_nodes >= v.min_nodes && v.desired_nodes <= v.max_nodes
    ])
    error_message = "For each node pool: min_nodes >= 0, max_nodes >= min_nodes, and min_nodes <= desired_nodes <= max_nodes"
  }
}

variable "enable_oidc" {
  description = "Enable OIDC authentication for the cluster"
  type        = bool
  default     = false
}

variable "oidc_config" {
  description = "OIDC configuration for cluster authentication"
  type = object({
    client_id          = string
    issuer_url         = string
    username_claim     = optional(string, "sub")
    username_prefix    = optional(string, "oidc:")
    groups_claim       = optional(list(string), [])
    groups_prefix      = optional(string, "oidc:")
    required_claim     = optional(list(string), [])
    signing_algs       = optional(list(string), ["RS256"])
  })
  default = null
}

variable "admission_plugins_enabled" {
  description = "List of admission plugins to enable"
  type        = list(string)
  default     = ["NodeRestriction", "AlwaysPullImages"]
}

variable "admission_plugins_disabled" {
  description = "List of admission plugins to disable"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    project    = "movetoeucloud"
  }
}
