output "private_network_id" {
  description = "ID of the private network"
  value       = ovh_cloud_project_network_private.private_network.id
}

output "private_network_openstack_id" {
  description = "OpenStack ID of the private network (used by Kubernetes)"
  value       = local.private_network_openstack_id
}

output "private_network_regions" {
  description = "Regions where the private network is available"
  value       = ovh_cloud_project_network_private.private_network.regions_attributes
}

output "nodes_subnet_id" {
  description = "ID of the Kubernetes nodes subnet"
  value       = ovh_cloud_project_network_private_subnet.nodes_subnet.id
}

output "nodes_subnet_cidr" {
  description = "CIDR block of the nodes subnet"
  value       = var.nodes_subnet_cidr
}

output "lb_subnet_id" {
  description = "ID of the load balancers subnet"
  value       = ovh_cloud_project_network_private_subnet.lb_subnet.id
}

output "lb_subnet_cidr" {
  description = "CIDR block of the load balancers subnet"
  value       = var.lb_subnet_cidr
}

output "region" {
  description = "Region where network resources are deployed"
  value       = var.region
}

output "gateway_id" {
  description = "ID of the gateway"
  value       = ovh_cloud_project_gateway.gateway.id
}

output "gateway_subnet_id" {
  description = "ID of the gateway subnet"
  value       = ovh_cloud_project_gateway.gateway.subnet_id
}