# Managed Kubernetes Cluster
resource "ovh_cloud_project_kube" "cluster" {
  service_name = var.ovh_project_id
  name         = var.cluster_name
  region       = var.region
  version      = var.kubernetes_version != "" ? var.kubernetes_version : null

  # Private network configuration
  private_network_id = var.private_network_id

  private_network_configuration {
    default_vrack_gateway            = var.default_vrack_gateway != "" ? var.default_vrack_gateway : null
    private_network_routing_as_default = var.private_network_routing_as_default
  }

  # Update policy
  update_policy = var.update_policy

  # Kube-proxy configuration
  kube_proxy_mode = var.kube_proxy_mode

  # Customization for API server
  customization_apiserver {
    admissionplugins {
      enabled  = var.admission_plugins_enabled
      disabled = var.admission_plugins_disabled
    }
  }
}

# Node Pools
resource "ovh_cloud_project_kube_nodepool" "pools" {
  for_each = var.node_pools

  service_name = var.ovh_project_id
  kube_id      = ovh_cloud_project_kube.cluster.id
  name         = each.key

  # Flavor and sizing
  flavor_name   = each.value.flavor_name
  desired_nodes = each.value.desired_nodes
  min_nodes     = each.value.min_nodes
  max_nodes     = each.value.max_nodes

  # Features
  autoscale      = each.value.autoscale
  monthly_billed = each.value.monthly_billed
  anti_affinity  = each.value.anti_affinity

  # The node pool will automatically use the cluster's private network configuration
  # including the nodes_subnet_id that we configured
}

# OIDC Configuration (Optional)
resource "ovh_cloud_project_kube_oidc" "oidc" {
  count = var.enable_oidc && var.oidc_config != null ? 1 : 0

  service_name = var.ovh_project_id
  kube_id      = ovh_cloud_project_kube.cluster.id

  client_id          = var.oidc_config.client_id
  issuer_url         = var.oidc_config.issuer_url
  oidc_username_claim = var.oidc_config.username_claim
  oidc_username_prefix = var.oidc_config.username_prefix
  oidc_groups_claim   = var.oidc_config.groups_claim
  oidc_groups_prefix  = var.oidc_config.groups_prefix
  oidc_required_claim = var.oidc_config.required_claim
  oidc_signing_algs   = var.oidc_config.signing_algs
}

# Local values
locals {
  cluster_tags = merge(
    var.tags,
    {
      cluster_name = var.cluster_name
      region       = var.region
    }
  )
}
