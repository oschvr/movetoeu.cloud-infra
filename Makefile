# Makefile for movetoeu.cloud Infrastructure Management
# Provider: OVH

.PHONY: help init-all plan-all apply-all destroy-all validate fmt clean

# Default target
help:
	@echo "movetoeu.cloud Infrastructure - OVH Provider"
	@echo ""
	@echo "Available targets:"
	@echo "  init-all     - Initialize all Terraform workspaces"
	@echo "  plan-all     - Run terraform plan on all workspaces"
	@echo "  apply-all    - Apply all workspaces in order"
	@echo "  destroy-all  - Destroy all resources (in reverse order)"
	@echo "  validate     - Validate all Terraform configurations"
	@echo "  fmt          - Format all Terraform files"
	@echo "  clean        - Remove .terraform directories and lock files"
	@echo ""
	@echo "Individual workspace targets:"
	@echo "  init-common, plan-common, apply-common, destroy-common"
	@echo "  init-network, plan-network, apply-network, destroy-network"
	@echo "  init-k8s, plan-k8s, apply-k8s, destroy-k8s"

# Initialize all workspaces
init-all: init-common init-network init-k8s

init-common:
	@echo "Initializing common workspace..."
	cd ovh/common && terraform init

init-network:
	@echo "Initializing network workspace..."
	cd ovh/network && terraform init

init-k8s:
	@echo "Initializing kubernetes workspace..."
	cd ovh/kubernetes && terraform init

# Plan all workspaces
plan-all: plan-common plan-network plan-k8s

plan-common:
	@echo "Planning common workspace..."
	cd ovh/common && terraform plan

plan-network:
	@echo "Planning network workspace..."
	cd ovh/network && terraform plan

plan-k8s:
	@echo "Planning kubernetes workspace..."
	cd ovh/kubernetes && terraform plan

# Apply all workspaces in order
apply-all: apply-common apply-network apply-k8s

apply-common:
	@echo "Applying common workspace..."
	cd ovh/common && terraform apply

apply-network:
	@echo "Applying network workspace..."
	cd ovh/network && terraform apply

apply-k8s:
	@echo "Applying kubernetes workspace..."
	cd ovh/kubernetes && terraform apply

# Destroy all resources in reverse order
destroy-all: destroy-k8s destroy-network

destroy-k8s:
	@echo "Destroying kubernetes workspace..."
	cd ovh/kubernetes && terraform destroy

destroy-network:
	@echo "Destroying network workspace..."
	cd ovh/network && terraform destroy

# Validate all configurations
validate:
	@echo "Validating common workspace..."
	cd ovh/common && terraform validate
	@echo "Validating network workspace..."
	cd ovh/network && terraform validate
	@echo "Validating kubernetes workspace..."
	cd ovh/kubernetes && terraform validate
	@echo "All configurations are valid!"

# Format all Terraform files
fmt:
	@echo "Formatting all Terraform files..."
	terraform fmt -recursive ovh/

# Clean terraform artifacts
clean:
	@echo "Cleaning Terraform artifacts..."
	find ovh -type d -name ".terraform" -exec rm -rf {} +
	find ovh -type f -name ".terraform.lock.hcl" -delete
	find ovh -type f -name "*.tfstate*" -delete
	@echo "Clean complete!"

# Get kubeconfig
get-kubeconfig:
	@echo "Extracting kubeconfig..."
	cd ovh/kubernetes && terraform output -raw kubeconfig > ~/.kube/config-movetoeu-ovh
	@echo "Kubeconfig saved to ~/.kube/config-movetoeu-ovh"
	@echo "Run: export KUBECONFIG=~/.kube/config-movetoeu-ovh"

# Show cluster info
cluster-info:
	cd ovh/kubernetes && terraform output cluster_url
	cd ovh/kubernetes && terraform output cluster_version
	cd ovh/kubernetes && terraform output cluster_status

# Show network info
network-info:
	cd ovh/network && terraform output
