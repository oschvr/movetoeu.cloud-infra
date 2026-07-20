output "cluster_id" {
  description = "Kubernetes cluster ID"
  value       = ovh_cloud_project_kube.cluster.id
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = ovh_cloud_project_kube.cluster.name
}

output "cluster_url" {
  description = "Kubernetes API server URL"
  value       = ovh_cloud_project_kube.cluster.url
}

output "cluster_version" {
  description = "Current Kubernetes version"
  value       = ovh_cloud_project_kube.cluster.version
}

output "cluster_status" {
  description = "Cluster status"
  value       = ovh_cloud_project_kube.cluster.status
}

output "kubeconfig" {
  description = "Kubernetes configuration file content"
  value       = ovh_cloud_project_kube.cluster.kubeconfig
  sensitive   = true
}

output "kubeconfig_attributes" {
  description = "Parsed kubeconfig attributes"
  value = {
    host                   = try(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].host, "")
    cluster_ca_certificate = try(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].cluster_ca_certificate, "")
    client_certificate     = try(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].client_certificate, "")
    client_key             = try(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].client_key, "")
  }
  sensitive = true
}

output "control_plane_is_up_to_date" {
  description = "Whether the control plane is up to date"
  value       = ovh_cloud_project_kube.cluster.control_plane_is_up_to_date
}

output "is_up_to_date" {
  description = "Whether the cluster is fully up to date"
  value       = ovh_cloud_project_kube.cluster.is_up_to_date
}

output "next_upgrade_versions" {
  description = "Available upgrade versions"
  value       = ovh_cloud_project_kube.cluster.next_upgrade_versions
}

output "nodes_url" {
  description = "URL to access cluster nodes"
  value       = ovh_cloud_project_kube.cluster.nodes_url
}

output "update_policy" {
  description = "Cluster update policy"
  value       = ovh_cloud_project_kube.cluster.update_policy
}

output "node_pool_ids" {
  description = "Map of node pool names to their IDs"
  value = {
    for k, v in ovh_cloud_project_kube_nodepool.pools : k => v.id
  }
}

output "node_pools_info" {
  description = "Detailed information about node pools"
  value = {
    for k, v in ovh_cloud_project_kube_nodepool.pools : k => {
      id             = v.id
      flavor         = v.flavor
      current_nodes  = v.current_nodes
      available_nodes = v.available_nodes
      desired_nodes  = v.desired_nodes
      min_nodes      = v.min_nodes
      max_nodes      = v.max_nodes
      autoscale      = v.autoscale
      status         = v.status
      created_at     = v.created_at
      updated_at     = v.updated_at
    }
  }
}

output "region" {
  description = "Cluster region"
  value       = var.region
}

output "oidc_enabled" {
  description = "Whether OIDC is enabled"
  value       = var.enable_oidc && var.oidc_config != null
}

# Helper output for kubectl configuration
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "terraform output -raw kubeconfig > ~/.kube/config-${var.cluster_name} && export KUBECONFIG=~/.kube/config-${var.cluster_name}"
}
