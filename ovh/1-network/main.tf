# Private Network (vRack)
resource "ovh_cloud_project_network_private" "private_network" {
  service_name = var.ovh_project_id
  name         = var.network_name
  regions      = [var.region]
  vlan_id      = var.vlan_id
}

# Subnet for Kubernetes Nodes
resource "ovh_cloud_project_network_private_subnet" "nodes_subnet" {
  service_name = var.ovh_project_id
  network_id   = ovh_cloud_project_network_private.private_network.id
  region       = var.region

  start      = var.nodes_subnet_start
  end        = var.nodes_subnet_end
  network    = var.nodes_subnet_cidr
  dhcp       = true
  no_gateway = false
}

# Subnet for Load Balancers
resource "ovh_cloud_project_network_private_subnet" "lb_subnet" {
  service_name = var.ovh_project_id
  network_id   = ovh_cloud_project_network_private.private_network.id
  region       = var.region

  start      = var.lb_subnet_start
  end        = var.lb_subnet_end
  network    = var.lb_subnet_cidr
  dhcp       = true
  no_gateway = false
}

resource "ovh_cloud_project_gateway" "gateway" {
  service_name = var.ovh_project_id
  name         = "movetoeucloud-gateway"
  model        = "s"
  region       = var.region
  network_id   = local.private_network_openstack_id
  subnet_id    = ovh_cloud_project_network_private_subnet.nodes_subnet.id
}

locals {
  # Extract OpenStack network ID for the region
  private_network_openstack_id = tolist(ovh_cloud_project_network_private.private_network.regions_attributes[*].openstackid)[0]
}
