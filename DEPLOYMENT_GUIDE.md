# OVH Kubernetes Deployment Guide

Complete walkthrough for deploying a production-ready Kubernetes cluster on OVH Cloud.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup Steps](#setup-steps)
3. [Network Configuration](#network-configuration)
4. [Cluster Deployment](#cluster-deployment)
5. [Post-Deployment](#post-deployment)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Accounts & Access

1. **OVH Account**
   - Sign up: https://www.ovh.com/auth/signup/
   - Add payment method
   - Activate Public Cloud service

2. **OVH API Credentials**
   - Create at: https://api.ovh.com/createToken/
   - Required permissions: GET, POST, PUT, DELETE on `/cloud/*`
   - Save: Application Key, Application Secret, Consumer Key

3. **Public Cloud Project**
   - Create in OVH Control Panel
   - Note the Project ID

4. **Local Tools**
   ```bash
   # Terraform
   brew install terraform  # macOS
   # or download from https://terraform.io
   
   # kubectl
   brew install kubectl
   
   # OVH CLI (optional but recommended)
   pip install ovhai
   ```

### Cost Estimate

Before deploying, estimate your monthly costs:
- Development cluster (2 x b2-7): ~€50/month
- Production cluster (3 x b2-15): ~€200/month
- High availability (multi-pool): ~€400-500/month

See pricing: https://www.ovhcloud.com/en/public-cloud/prices/

## Setup Steps

### Step 1: Clone and Prepare

```bash
# Clone the repository
git clone <your-repo-url> movetoeu-infrastructure
cd movetoeu-infrastructure/ovh
```

### Step 2: Configure Common (Provider Setup)

```bash
cd common

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Required values:
# - ovh_application_key
# - ovh_application_secret
# - ovh_consumer_key
# - ovh_project_id

# Initialize and validate
terraform init
terraform validate
terraform plan

# Apply
terraform apply
```

**Outputs to Note:**
- `project_id` - needed for next steps

### Step 3: Configure Network

```bash
cd ../network

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Key decisions:
# - region: Where to deploy (GRA11, SBG5, WAW1, DE1, UK1)
# - network_name: Descriptive name for your private network
# - Subnet CIDRs: Usually defaults are fine

# Initialize and apply
terraform init
terraform plan
terraform apply
```

**Important Outputs:**
```bash
# Save these for the Kubernetes workspace
terraform output private_network_openstack_id
terraform output nodes_subnet_id
terraform output lb_subnet_id
```

### Step 4: Deploy Kubernetes Cluster

```bash
cd ../kubernetes

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Critical Configuration:**

1. **Network Integration** (from Step 3 outputs):
   ```hcl
   private_network_id = "abc123..."  # from terraform output
   nodes_subnet_id    = "def456..."
   lb_subnet_id       = "ghi789..."
   ```

2. **Choose Node Pool Profile**:
   - Uncomment one of the profiles in terraform.tfvars
   - Or create custom configuration

3. **Region Match**:
   ```hcl
   region = "GRA11"  # MUST match network region
   ```

Deploy:
```bash
terraform init
terraform plan

# Review the plan carefully
# Verify node counts, flavors, and costs

terraform apply
```

## Post-Deployment

### Access Your Cluster

```bash
# Get kubeconfig
cd ovh/kubernetes
terraform output -raw kubeconfig > ~/.kube/config-ovh

# Use the cluster
export KUBECONFIG=~/.kube/config-ovh
kubectl get nodes
kubectl get pods -A
```

### Verify Cluster Health

```bash
# Check nodes are ready
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check cluster info
kubectl cluster-info

# Verify private networking
kubectl get nodes -o wide
```

### Install Essential Components

```bash
# Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Cert-Manager (for TLS)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### Set Up Storage

OVH provides Cinder CSI driver by default:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: csi-cinder-high-speed
```

### Configure Load Balancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: my-app
```

## Advanced Configuration

### Enable Monitoring

```bash
# Prometheus + Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

### Set Up GitOps with ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### Configure Autoscaling

Node pool autoscaling is configured via Terraform. For pod autoscaling:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Troubleshooting

### Cluster Creation Stuck

```bash
# Check OVH Control Panel for status
# Visit: Public Cloud > Managed Kubernetes

# Check Terraform logs
terraform refresh
terraform show

# Destroy and recreate if needed
terraform destroy
terraform apply
```

### Nodes Not Ready

```bash
# Check node status
kubectl describe node <node-name>

# Check kubelet logs (via OVH Control Panel)
# Or SSH if enabled

# Verify private network connectivity
kubectl get pods -n kube-system -o wide
```

### Network Issues

```bash
# Verify network resources in OVH Control Panel
# Check: Public Cloud > Private Network

# Verify subnets
cd ../network
terraform show

# Check cluster network config
cd ../kubernetes
terraform show | grep -A 10 private_network
```

### Can't Access Services

```bash
# Check load balancer creation
kubectl get svc -A | grep LoadBalancer

# Check OVH Control Panel:
# Public Cloud > Load Balancer

# Verify security groups allow traffic
# (OVH managed K8s handles this automatically)
```

### Upgrade Issues

```bash
# Check available versions
terraform output next_upgrade_versions

# Update terraform.tfvars
kubernetes_version = "1.29"

# Plan and apply
terraform plan
terraform apply
```

## Cleanup

```bash
# Delete cluster and node pools
cd ovh/kubernetes
terraform destroy

# Delete network resources
cd ../network
terraform destroy

# Note: Common workspace typically stays
# (contains only provider configuration)
```

## Next Steps

- Set up CI/CD pipelines
- Configure backup strategy with Velero
- Implement pod security policies
- Set up centralized logging
- Configure network policies
- Plan disaster recovery procedures

## Support Resources

- OVH Documentation: https://docs.ovh.com/
- Terraform OVH Provider: https://registry.terraform.io/providers/ovh/ovh/latest/docs
- OVH Community: https://community.ovh.com/
- Kubernetes Documentation: https://kubernetes.io/docs/
