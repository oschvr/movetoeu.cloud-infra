# movetoeu.cloud Infrastructure Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         movetoeu.cloud                              │
│                    Landing Page & Configurator                      │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          │ User Selects:
                          │ 1. Cloud Provider (OVH/Scaleway/UpCloud)
                          │ 2. Region (GRA11, WAW1, etc.)
                          │ 3. Cluster Type (General/Compute/Memory)
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Generated Terraform Code                         │
│                  (GitHub Repository Download)                       │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          │ User Downloads & Deploys
                          │
                          ▼
```

## OVH Deployment Flow

```
Step 1: COMMON                Step 2: NETWORK              Step 3: KUBERNETES
┌──────────────┐             ┌──────────────┐             ┌──────────────┐
│              │             │              │             │              │
│ Provider     │────────────▶│ vRack        │────────────▶│ Cluster      │
│ Setup        │             │ Private Net  │             │ Creation     │
│              │             │              │             │              │
│ • API Keys   │             │ • Network    │             │ • K8s API    │
│ • Project ID │             │ • Subnets    │             │ • Node Pools │
│ • Validation │             │   - Nodes    │             │ • Auto-scale │
│              │             │   - LBs      │             │ • OIDC       │
└──────────────┘             └──────────────┘             └──────────────┘
      │                            │                            │
      │                            │                            │
      └────────────────────────────┴────────────────────────────┘
                                   │
                                   ▼
                        ┌──────────────────────┐
                        │  Running Cluster     │
                        │  • kubeconfig ready  │
                        │  • Private network   │
                        │  • Auto-scaling      │
                        │  • Production-ready  │
                        └──────────────────────┘
```

## Detailed OVH Infrastructure

```
┌─────────────────────────────────────────────────────────────────────┐
│                        OVH Public Cloud Project                     │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                   ┌───────────────┴───────────────┐
                   │                               │
         ┌─────────▼─────────┐         ┌──────────▼─────────┐
         │   vRack Network   │         │  Internet Gateway  │
         │  (Private L2/L3)  │         │   (Public Access)  │
         └─────────┬─────────┘         └──────────┬─────────┘
                   │                               │
         ┌─────────┴─────────┐                    │
         │                   │                    │
    ┌────▼────┐         ┌────▼────┐              │
    │ Nodes   │         │ Load    │              │
    │ Subnet  │         │Balancers│              │
    │         │         │ Subnet  │              │
    │192.168  │         │192.168  │              │
    │ .0.0/24 │         │ .1.0/24 │              │
    └────┬────┘         └────┬────┘              │
         │                   │                   │
         │                   │                   │
┌────────┴────────┐  ┌───────┴────────┐  ┌──────┴───────┐
│  Kubernetes     │  │  Kubernetes    │  │ Load         │
│  Master Nodes   │  │  Worker Nodes  │  │ Balancers    │
│  (Managed/Free) │  │                │  │              │
│                 │  │  ┌──────────┐  │  │ ┌──────────┐ │
│  • Control      │  │  │ Node Pool│  │  │ │ Service  │ │
│    Plane        │  │  │  #1      │  │  │ │ Type: LB │ │
│  • etcd         │  │  │  b2-7    │  │  │ └──────────┘ │
│  • API Server   │  │  │  (2-10)  │  │  │              │
│                 │  │  └──────────┘  │  │ ┌──────────┐ │
└─────────────────┘  │                │  │ │ Ingress  │ │
                     │  ┌──────────┐  │  │ │ NGINX    │ │
                     │  │ Node Pool│  │  │ └──────────┘ │
                     │  │  #2      │  │  │              │
                     │  │ (Optional)│  │  └──────────────┘
                     │  └──────────┘  │
                     └────────────────┘
```

## Network Traffic Flow

```
External User Request
        │
        ▼
┌───────────────┐
│ Public IP     │
│ Load Balancer │ ◀── Provisioned automatically by K8s
└───────┬───────┘     Service type: LoadBalancer
        │
        │ (Public → Private subnet 192.168.1.0/24)
        │
        ▼
┌───────────────┐
│ Ingress       │
│ Controller    │ ◀── NGINX/Traefik in cluster
└───────┬───────┘
        │
        │ (Private network)
        │
        ▼
┌───────────────┐
│ Pod Network   │
│ (CNI: Flannel)│ ◀── Internal pod communication
└───────┬───────┘
        │
        │
        ▼
┌───────────────┐
│ Application   │
│ Pods          │ ◀── Your workloads
└───────────────┘
```

## Multi-Region Deployment Pattern

```
                        ┌─────────────────┐
                        │  CloudFlare     │
                        │  DNS / LB       │
                        └────────┬────────┘
                                 │
                ┌────────────────┼────────────────┐
                │                │                │
        ┌───────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
        │ GRA (France) │ │ WAW (Poland)│ │ DE (Germany)│
        │   Cluster    │ │  Cluster    │ │  Cluster    │
        └──────────────┘ └─────────────┘ └─────────────┘
                │                │                │
                └────────────────┼────────────────┘
                                 │
                        ┌────────▼────────┐
                        │ Shared Storage  │
                        │ (Object Storage)│
                        │  Replication    │
                        └─────────────────┘
```

## Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 7: Application Security                              │
│ • Pod Security Policies                                    │
│ • Network Policies (Calico/Cilium)                        │
│ • RBAC (Role-Based Access Control)                        │
│ • Secrets Management (External Secrets Operator)          │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 6: Cluster Security                                  │
│ • OIDC Authentication                                      │
│ • Admission Controllers (NodeRestriction, etc.)           │
│ • Private API Endpoint                                    │
│ • TLS Everywhere                                          │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 5: Network Security                                  │
│ • Private Network (vRack) - No Internet routing           │
│ • Security Groups (OVH managed)                           │
│ • DDoS Protection (OVH Anti-DDoS)                         │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Infrastructure Security                           │
│ • Encrypted Volumes (LUKS)                                │
│ • Secure Boot                                             │
│ • Regular Security Patches (Auto-update)                  │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Data Center Security                              │
│ • ISO 27001 Certified                                     │
│ • Physical Access Control                                 │
│ • Redundant Power & Cooling                              │
│ • GDPR Compliant (EU locations only)                     │
└─────────────────────────────────────────────────────────────┘
```

## Terraform State Management (Production Setup)

```
Developer Workstation                   Remote State Backend
┌────────────────────┐                 ┌────────────────────┐
│                    │                 │ OVH Object Storage │
│ terraform apply    │────────────────▶│ (S3-compatible)    │
│                    │   State Lock    │                    │
│ Local Terraform    │◀────────────────│ • terraform.tfstate│
│ Working Directory  │   State Read    │ • Lock Table       │
│                    │                 │ • Versioning       │
└────────────────────┘                 └────────────────────┘
         │                                      │
         │                                      │
         ▼                                      ▼
┌────────────────────┐                 ┌────────────────────┐
│ OVH API            │                 │ State Encryption   │
│ Resource Creation  │                 │ • Server-side AES  │
│                    │                 │ • Access Logs      │
└────────────────────┘                 └────────────────────┘
```

## Scaling Strategy

```
Traffic Increase                Auto-Scaling Response
     │                                  │
     │  Light Load                      │  Min Nodes (1-3)
     │  ─────────────────────           │  Running
     │                                  │
     │                                  │
     │  ↑ Medium Load                   │  ↑ Scale Up
     │  ─────────────────────           │  Add Nodes (4-7)
     │                                  │  HPA triggers
     │                                  │
     │                                  │
     │  ↑↑ Heavy Load                   │  ↑↑ Max Scale
     │  ─────────────────────           │  Max Nodes (8-10)
     │                                  │  All pods running
     │                                  │
     │                                  │
     │  ↓ Load Decreases                │  ↓ Scale Down
     │  ─────────────────────           │  Remove Nodes
     │                                  │  Graceful shutdown
     │                                  │
     │  Low Load                        │  Min Nodes
     └──────────────────────            └──────────────────
```

## Disaster Recovery Architecture

```
Primary Region (GRA)              Backup Region (WAW)
┌─────────────────┐              ┌─────────────────┐
│ Active Cluster  │              │ Standby Cluster │
│                 │              │                 │
│ • Production    │─────────────▶│ • Cold/Warm     │
│ • All Traffic   │   Velero     │ • Ready for DR  │
│                 │   Backup     │                 │
└────────┬────────┘              └────────┬────────┘
         │                                │
         │                                │
         ▼                                ▼
┌─────────────────────────────────────────────────┐
│        OVH Object Storage (Replicated)          │
│                                                 │
│ • Application Backups (Velero)                 │
│ • etcd Snapshots                               │
│ • Persistent Volume Snapshots                  │
│ • Configuration Backups                        │
└─────────────────────────────────────────────────┘
```

## Cost Optimization Flow

```
                    Workload Analysis
                          │
          ┌───────────────┼───────────────┐
          │               │               │
    ┌─────▼────┐    ┌─────▼────┐   ┌─────▼────┐
    │ Stable   │    │Variable  │   │ Burst    │
    │ Workload │    │ Workload │   │ Workload │
    └─────┬────┘    └─────┬────┘   └─────┬────┘
          │               │               │
          ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐   ┌──────────┐
    │ Monthly  │    │ Hourly   │   │ Spot     │
    │ Billing  │    │ + Auto-  │   │ Instances│
    │ (30%off) │    │ Scale    │   │ (Future) │
    └──────────┘    └──────────┘   └──────────┘
          │               │               │
          └───────────────┼───────────────┘
                          │
                    Total Savings:
                    30-50% vs Big 3
```

## Future Multi-Provider Architecture

```
movetoeu.cloud Control Plane
         │
         │  Unified Terraform Interface
         │
┌────────┼────────┬────────┬────────┐
│        │        │        │        │
▼        ▼        ▼        ▼        │
OVH    Scaleway  UpCloud  Hetzner  │
Cluster Cluster  Cluster  (Future) │
  │       │        │        │       │
  └───────┴────────┴────────┴───────┘
            │
    Unified Ingress / Service Mesh
            │
      User Applications
```

---

All diagrams created with ASCII art for maximum portability and easy rendering in markdown viewers.
