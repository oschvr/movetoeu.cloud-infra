#!/bin/bash
# Quick Start Setup Script for movetoeu.cloud - OVH Provider
# This script helps you set up your first Kubernetes cluster

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}movetoeu.cloud - OVH Kubernetes Quick Start${NC}"
echo "=============================================="
echo ""

# Check prerequisites
echo -e "${BOLD}Checking prerequisites...${NC}"

command -v terraform >/dev/null 2>&1 || {
    echo -e "${RED}Error: terraform is not installed${NC}"
    echo "Install from: https://terraform.io/downloads"
    exit 1
}

command -v kubectl >/dev/null 2>&1 || {
    echo -e "${YELLOW}Warning: kubectl is not installed${NC}"
    echo "You'll need it to access your cluster later"
    echo "Install from: https://kubernetes.io/docs/tasks/tools/"
}

echo -e "${GREEN}✓ Prerequisites checked${NC}"
echo ""

# Gather configuration
echo -e "${BOLD}Configuration Setup${NC}"
echo "This script will help you configure your OVH Kubernetes cluster."
echo ""

read -p "Have you created OVH API credentials? (y/n): " has_creds
if [ "$has_creds" != "y" ]; then
    echo -e "${YELLOW}Please create API credentials first:${NC}"
    echo "1. Visit: https://api.ovh.com/createToken/"
    echo "2. Set rights: GET, POST, PUT, DELETE on /cloud/*"
    echo "3. Save Application Key, Application Secret, and Consumer Key"
    echo ""
    read -p "Press Enter when ready to continue..."
fi

echo ""
echo "Enter your OVH API credentials:"
read -p "Application Key: " app_key
read -sp "Application Secret: " app_secret
echo ""
read -sp "Consumer Key: " consumer_key
echo ""
read -p "Project ID: " project_id
echo ""

# Region selection
echo ""
echo -e "${BOLD}Select your region:${NC}"
echo "1) GRA11 (Gravelines, France) - Recommended"
echo "2) SBG5 (Strasbourg, France)"
echo "3) WAW1 (Warsaw, Poland)"
echo "4) DE1 (Frankfurt, Germany)"
echo "5) UK1 (London, United Kingdom)"
read -p "Enter choice [1-5]: " region_choice

case $region_choice in
    1) region="GRA11";;
    2) region="SBG5";;
    3) region="WAW1";;
    4) region="DE1";;
    5) region="UK1";;
    *) echo "Invalid choice"; exit 1;;
esac

echo ""
read -p "Cluster name [production-k8s]: " cluster_name
cluster_name=${cluster_name:-production-k8s}

# Cluster profile selection
echo ""
echo -e "${BOLD}Select cluster profile:${NC}"
echo "1) Development (2x b2-7) - ~€50/month"
echo "2) Production (3x b2-15) - ~€200/month"
echo "3) High Availability (multi-pool) - ~€400/month"
echo "4) Custom (configure manually later)"
read -p "Enter choice [1-4]: " profile_choice

# Generate tfvars files
echo ""
echo -e "${BOLD}Generating configuration files...${NC}"

# Common workspace
cat > ovh/common/terraform.tfvars <<EOF
ovh_endpoint           = "ovh-eu"
ovh_application_key    = "${app_key}"
ovh_application_secret = "${app_secret}"
ovh_consumer_key       = "${consumer_key}"
ovh_project_id         = "${project_id}"
project_description    = "movetoeu.cloud - EU Sovereign Kubernetes"
EOF

echo -e "${GREEN}✓ Created ovh/common/terraform.tfvars${NC}"

# Network workspace
cat > ovh/network/terraform.tfvars <<EOF
ovh_endpoint           = "ovh-eu"
ovh_application_key    = "${app_key}"
ovh_application_secret = "${app_secret}"
ovh_consumer_key       = "${consumer_key}"
ovh_project_id         = "${project_id}"

region       = "${region}"
network_name = "k8s-private-network"
vlan_id      = 0

nodes_subnet_cidr  = "192.168.0.0/24"
nodes_subnet_start = "192.168.0.10"
nodes_subnet_end   = "192.168.0.250"

lb_subnet_cidr  = "192.168.1.0/24"
lb_subnet_start = "192.168.1.10"
lb_subnet_end   = "192.168.1.250"
EOF

echo -e "${GREEN}✓ Created ovh/network/terraform.tfvars${NC}"

# Initialize and apply network first
echo ""
echo -e "${BOLD}Setting up network...${NC}"
cd ovh/network
terraform init
terraform apply -auto-approve
echo -e "${GREEN}✓ Network created${NC}"

# Get network outputs
private_network_id=$(terraform output -raw private_network_openstack_id)
nodes_subnet_id=$(terraform output -raw nodes_subnet_id)
lb_subnet_id=$(terraform output -raw lb_subnet_id)
cd ../..

# Kubernetes workspace
echo ""
echo -e "${BOLD}Creating Kubernetes configuration...${NC}"

node_pools=""
case $profile_choice in
    1)
        node_pools='node_pools = {
  "dev-pool" = {
    flavor_name    = "b2-7"
    desired_nodes  = 2
    min_nodes      = 1
    max_nodes      = 3
    autoscale      = true
    monthly_billed = false
    anti_affinity  = false
  }
}'
        ;;
    2)
        node_pools='node_pools = {
  "general-pool" = {
    flavor_name    = "b2-15"
    desired_nodes  = 3
    min_nodes      = 3
    max_nodes      = 10
    autoscale      = true
    monthly_billed = true
    anti_affinity  = true
  }
}'
        ;;
    3)
        node_pools='node_pools = {
  "system-pool" = {
    flavor_name    = "b2-15"
    desired_nodes  = 3
    min_nodes      = 3
    max_nodes      = 3
    autoscale      = false
    monthly_billed = true
    anti_affinity  = true
  }
  "app-pool" = {
    flavor_name    = "b2-30"
    desired_nodes  = 3
    min_nodes      = 2
    max_nodes      = 10
    autoscale      = true
    monthly_billed = false
    anti_affinity  = true
  }
}'
        ;;
    4)
        echo "Please edit ovh/kubernetes/terraform.tfvars manually"
        node_pools='# Configure your custom node pools here'
        ;;
esac

cat > ovh/kubernetes/terraform.tfvars <<EOF
ovh_endpoint           = "ovh-eu"
ovh_application_key    = "${app_key}"
ovh_application_secret = "${app_secret}"
ovh_consumer_key       = "${consumer_key}"
ovh_project_id         = "${project_id}"

cluster_name       = "${cluster_name}"
region             = "${region}"
kubernetes_version = ""
update_policy      = "MINIMAL_DOWNTIME"
kube_proxy_mode    = "iptables"

private_network_id                = "${private_network_id}"
nodes_subnet_id                   = "${nodes_subnet_id}"
lb_subnet_id                      = "${lb_subnet_id}"
private_network_routing_as_default = true
default_vrack_gateway             = ""

admission_plugins_enabled  = ["NodeRestriction", "AlwaysPullImages"]
admission_plugins_disabled = []

${node_pools}

enable_oidc = false

tags = {
  managed_by  = "terraform"
  project     = "movetoeucloud"
  environment = "production"
}
EOF

echo -e "${GREEN}✓ Created ovh/kubernetes/terraform.tfvars${NC}"

# Deploy cluster
if [ "$profile_choice" != "4" ]; then
    echo ""
    echo -e "${BOLD}Deploying Kubernetes cluster...${NC}"
    echo "This may take 10-15 minutes."
    echo ""

    cd ovh/kubernetes
    terraform init
    terraform apply

    echo ""
    echo -e "${GREEN}✓ Cluster deployed successfully!${NC}"

    # Save kubeconfig
    terraform output -raw kubeconfig > ~/.kube/config-${cluster_name}

    echo ""
    echo -e "${BOLD}Setup Complete!${NC}"
    echo ""
    echo "To access your cluster:"
    echo "  export KUBECONFIG=~/.kube/config-${cluster_name}"
    echo "  kubectl get nodes"
    echo ""
    echo "Cluster information:"
    terraform output cluster_url
    terraform output cluster_version
    echo ""
    echo "Next steps:"
    echo "  1. Install essential add-ons (see DEPLOYMENT_GUIDE.md)"
    echo "  2. Deploy your applications"
    echo "  3. Configure monitoring and logging"

else
    echo ""
    echo "Please edit ovh/kubernetes/terraform.tfvars and run:"
    echo "  cd ovh/kubernetes"
    echo "  terraform init"
    echo "  terraform apply"
fi
