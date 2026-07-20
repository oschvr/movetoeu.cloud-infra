# movetoeu.cloud Infrastructure

Production-grade Terraform automation for deploying managed Kubernetes clusters across European cloud providers.

## Supported Providers

- **OVH Cloud** - Full support with private networking
- **Scaleway** - Coming soon
- **UpCloud** - Coming soon

## Repository Structure

```
infrastructure/
├── ovh/
│   ├── common/          # IAM, API credentials, project setup
│   ├── network/         # VPC, subnets, security groups
│   └── kubernetes/      # Managed K8s cluster and node pools
├── scaleway/            # Coming soon
└── upcloud/             # Coming soon
```

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- OVH API credentials (application key, secret, consumer key)
  - Get your credentials from: https://api.ovh.com/createToken/
  - They have to have the scope `GET`, `PUT/PATCH`, `POST` and `DELETE` to `/cloud/*` `/v2/publicCloud/*`
  - https://manager.eu.ovhcloud.com/#/iam/api-keys
- OVH Public Cloud project

### Deploy OVH Kubernetes Cluster

```bash
cd infrastructure/ovh/common
terraform init
terraform apply

cd ../network
terraform init
terraform apply

cd ../kubernetes
terraform init
terraform apply
```

## Configuration

Each workspace contains:
- `variables.tf` - Input variables with defaults
- `main.tf` - Resource definitions
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example configuration
- `README.md` - Workspace-specific documentation

## Regional Availability

### OVH Regions
- GRA (Gravelines, France)
- SBG (Strasbourg, France)
- RBX (Roubaix, France)
- WAW (Warsaw, Poland)
- DE (Frankfurt, Germany)
- UK (London, United Kingdom)

## Features

✅ GDPR-compliant by default  
✅ Private networking with vRack  
✅ Auto-scaling node pools  
✅ Latest Kubernetes versions  
✅ Flexible instance types (general purpose, compute, memory)  
✅ Cost-optimized with spot instances option  
✅ Production-ready with backup strategies  

## License

MIT
