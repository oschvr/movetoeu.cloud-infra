output "instance_id" {
  description = "Compute instance ID"
  value       = ovh_cloud_project_instance.compute.id
}

output "instance_name" {
  description = "Compute instance name"
  value       = ovh_cloud_project_instance.compute.name
}

output "instance_status" {
  description = "Compute instance status"
  value       = ovh_cloud_project_instance.compute.status
}

output "instance_addresses" {
  description = "All IP addresses (public and private) assigned to the instance"
  value       = ovh_cloud_project_instance.compute.addresses
}

output "flavor_id" {
  description = "Resolved flavor ID used for the instance"
  value       = ovh_cloud_project_instance.compute.flavor_id
}

output "flavor_name" {
  description = "Resolved flavor name used for the instance"
  value       = ovh_cloud_project_instance.compute.flavor_name
}

output "image_id" {
  description = "Resolved image ID used for the instance"
  value       = ovh_cloud_project_instance.compute.image_id
}

output "ssh_key_name" {
  description = "Name of the SSH key registered and attached to the instance"
  value       = ovh_cloud_project_ssh_key.compute_key.name
}

output "ssh_connect_hint" {
  description = "Hint for connecting once the public IP is known via instance_addresses"
  value       = "ssh -i ~/.ssh/movetoeu.cloud ubuntu@<public_ip_from_instance_addresses>"
}
