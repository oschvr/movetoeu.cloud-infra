# OVH Network - Private Network & Subnets

This workspace creates:
- Private network (vRack integration)
- Subnets for Kubernetes nodes and load balancers
- Network configuration for the cluster

## Prerequisites

- Completed `common` workspace setup
- OVH Public Cloud project ID

## Network Architecture

```
Private Network (vRack)
├── Nodes Subnet (192.168.0.0/24)
│   ├── Range: 192.168.0.10 - 192.168.0.250
│   └── DHCP enabled
└── Load Balancers Subnet (192.168.1.0/24)
    ├── Range: 192.168.1.10 - 192.168.1.250
    └── DHCP enabled
```

## Setup

1. Copy the example configuration:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your project ID and region

3. Initialize and apply:
```bash
terraform init
terraform apply
```

## Outputs

- `private_network_id` - OpenStack ID of the private network
- `private_network_regions` - Network regions attributes
- `nodes_subnet_id` - Subnet ID for Kubernetes nodes
- `lb_subnet_id` - Subnet ID for load balancers

## Regional Support

Available regions:
- GRA (Gravelines, France)
- SBG (Strasbourg, France)
- RBX (Roubaix, France)
- WAW (Warsaw, Poland)
- DE (Frankfurt, Germany)
- UK (London, United Kingdom)

## Notes

- The private network uses vRack for isolation
- Subnets are automatically configured with DHCP
- Network IDs are passed to the Kubernetes workspace
