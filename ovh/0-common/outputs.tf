output "project_id" {
  description = "OVH Public Cloud project ID"
  value       = var.ovh_project_id
}

output "project_description" {
  description = "Project description"
  value       = var.project_description
}

output "ovh_endpoint" {
  description = "OVH API endpoint"
  value       = var.ovh_endpoint
}

output "regions" {
  description = "OVH regions"
  value       = flatten(data.ovh_cloud_project_regions.regions.names)
}