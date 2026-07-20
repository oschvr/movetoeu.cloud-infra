# OVH Kubernetes - Managed Kubernetes Cluster

This workspace creates:
- Managed Kubernetes cluster
- Node pools with auto-scaling
- Integration with private network
- OIDC configuration (optional)

## Prerequisites

- Completed `common` and `network` workspace setup
- Private network and subnets created
- Kubernetes version selection

## Cluster Configuration

### Supported Kubernetes Versions

Check available versions at: https://www.ovhcloud.com/en/public-cloud/kubernetes/

### Node Pool Types

**General Purpose** (Balanced CPU/Memory):
- `b2-7` - 2 vCPU, 7 GB RAM
- `b2-15` - 4 vCPU, 15 GB RAM
- `b2-30` - 8 vCPU, 30 GB RAM
- `b2-60` - 16 vCPU, 60 GB RAM

**Compute Optimized** (High CPU):
- `c2-7` - 2 vCPU, 7 GB RAM
- `c2-15` - 4 vCPU, 15 GB RAM
- `c2-30` - 8 vCPU, 30 GB RAM
- `c2-60` - 16 vCPU, 60 GB RAM

**Memory Optimized** (High RAM):
- `r2-15` - 2 vCPU, 15 GB RAM
- `r2-30` - 4 vCPU, 30 GB RAM
- `r2-60` - 8 vCPU, 60 GB RAM
- `r2-120` - 16 vCPU, 120 GB RAM

Full flavor list: https://www.ovhcloud.com/en/public-cloud/prices/

## Setup

1. Complete network workspace first to get network IDs

2. Copy the example configuration:
```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Edit `terraform.tfvars` with your configuration

4. Initialize and apply:
```bash
terraform init
terraform apply
```

## Outputs

- `cluster_id` - Kubernetes cluster ID
- `cluster_name` - Cluster name
- `cluster_url` - Cluster API endpoint
- `kubeconfig` - Kubernetes configuration (sensitive)
- `cluster_version` - Current Kubernetes version
- `node_pool_ids` - Map of node pool IDs

## Accessing the Cluster

### Download kubeconfig

```bash
terraform output -raw kubeconfig > ~/.kube/config-ovh-cluster
export KUBECONFIG=~/.kube/config-ovh-cluster
kubectl get nodes
```

### Via OVH CLI

```bash
ovhai kube update-config <cluster-id>
kubectl get nodes
```

## Auto-scaling

Node pools support auto-scaling with configurable min/max nodes:

```hcl
node_pools = {
  "general-pool" = {
    flavor_name  = "b2-7"
    desired_nodes = 3
    min_nodes    = 1
    max_nodes    = 10
    autoscale    = true
  }
}
```

## Update Policy

Choose cluster update behavior:
- `ALWAYS_UPDATE` - Automatic updates to latest patch version
- `MINIMAL_DOWNTIME` - Updates with minimal service disruption
- `NEVER_UPDATE` - Manual updates only

## Network Configuration

The cluster is deployed in a private network with:
- Nodes in dedicated subnet (192.168.0.0/24)
- Load balancers in separate subnet (192.168.1.0/24)
- vRack integration for network isolation
- Default route via private network gateway

## OIDC (Optional)

Configure OIDC for authentication:

```hcl
enable_oidc = true
oidc_config = {
  client_id    = "kubernetes"
  issuer_url   = "https://your-identity-provider.com"
  username_claim = "email"
}
```

## Cost Optimization

- Use `monthly_billed = true` for ~30% discount on stable workloads
- Configure appropriate min_nodes to avoid over-provisioning
- Use smaller flavors where appropriate
- Enable autoscaling for variable workloads

## Monitoring & Logs

OVH provides:
- Integrated cluster monitoring in Control Panel
- Logs via OVH Logs Data Platform integration
- Metrics export to Prometheus

## Disaster Recovery

Recommendations:
- Enable etcd backups via OVH backup service
- Use Velero for application backups
- Store kubeconfig securely
- Document cluster configuration

## Regional Deployment

Ensure all resources (network, cluster, node pools) use the same region:
- GRA11 (Gravelines, France) - Recommended
- SBG5 (Strasbourg, France)
- WAW1 (Warsaw, Poland)
- DE1 (Frankfurt, Germany)
- UK1 (London, United Kingdom)
