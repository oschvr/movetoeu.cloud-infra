# EU Cloud Provider Comparison

This guide helps you choose the right European cloud provider for your Kubernetes workloads.

## Provider Overview

| Feature | OVH Cloud | Scaleway | UpCloud |
|---------|-----------|----------|---------|
| **Headquarters** | France | France | Finland |
| **Data Centers** | France, Poland, Germany, UK | France, Netherlands, Poland | Multiple EU locations |
| **GDPR Compliance** | ✓ Native | ✓ Native | ✓ Native |
| **ISO 27001** | ✓ | ✓ | ✓ |
| **Kubernetes** | Managed (Free control plane) | Managed | Managed |
| **Private Network** | vRack | Private Networks | Private Networks |
| **Load Balancers** | Included | Included | Included |
| **Block Storage** | Cinder (OpenStack) | Block Storage | MaxIOPS |
| **Object Storage** | S3-compatible | S3-compatible | S3-compatible |

## Pricing Comparison

### Managed Kubernetes Control Plane
- **OVH**: FREE
- **Scaleway**: FREE (3 nodes), then €0.10/node/hour
- **UpCloud**: Included with servers

### Compute Instances (2 vCPU, 7-8 GB RAM)

**OVH (b2-7):**
- Hourly: €0.0615/hour (~€45/month)
- Monthly: €31.78/month (30% savings)

**Scaleway (DEV1-M):**
- Hourly: €0.07/hour (~€51/month)
- No monthly billing

**UpCloud (2 vCPU, 8 GB):**
- Hourly: €0.073/hour (~€53/month)
- No monthly billing

### Storage Pricing (per GB/month)

| Type | OVH | Scaleway | UpCloud |
|------|-----|----------|---------|
| Block Storage | €0.04 | €0.08 | €0.08 |
| Object Storage | €0.01 | €0.01 | €0.015 |

## Regional Coverage

### OVH Regions
- **GRA** (Gravelines, France) - Primary DC, lowest latency to Western Europe
- **SBG** (Strasbourg, France) - Central Europe
- **RBX** (Roubaix, France)
- **WAW** (Warsaw, Poland) - Eastern Europe
- **DE** (Frankfurt, Germany)
- **UK** (London, United Kingdom)

### Scaleway Regions
- **PAR** (Paris, France)
- **AMS** (Amsterdam, Netherlands)
- **WAW** (Warsaw, Poland)

### UpCloud Regions
- **Frankfurt** (Germany)
- **London** (United Kingdom)
- **Amsterdam** (Netherlands)
- **Madrid** (Spain)
- Plus: Finland, Poland, Sweden

## Kubernetes Features

### OVH Managed Kubernetes
✅ **Pros:**
- Free control plane (no cost regardless of cluster size)
- OpenStack-based (standard APIs)
- Monthly billing available (30% discount)
- vRack private networking
- Integrated with OVH ecosystem
- Large instance variety

❌ **Cons:**
- Fewer managed add-ons
- Basic web UI
- Slower feature rollout vs competitors

### Scaleway Kubernetes (Kapsule)
✅ **Pros:**
- Modern UI and CLI
- Fast feature adoption
- Good documentation
- IPv6 support
- Integrated observability

❌ **Cons:**
- Control plane costs after 3 nodes
- Smaller instance selection
- Fewer regions

### UpCloud Managed Kubernetes
✅ **Pros:**
- High-performance MaxIOPS storage
- Flexible pricing
- Multiple EU locations
- Good performance

❌ **Cons:**
- Smaller ecosystem
- Limited managed services
- Less documentation

## Network Performance

Based on public benchmarks:

**Latency (Paris to Frankfurt):**
- OVH: ~8-10ms
- Scaleway: ~8-10ms
- UpCloud: ~8-12ms

**Bandwidth:**
- OVH: Up to 10 Gbps (varies by instance)
- Scaleway: Up to 10 Gbps
- UpCloud: Up to 10 Gbps

All providers offer private networking with no data transfer costs within the same region.

## Use Case Recommendations

### Choose OVH if:
- ✓ You want the lowest costs (free control plane + monthly billing)
- ✓ You're running larger clusters (>10 nodes)
- ✓ You need OpenStack compatibility
- ✓ You want mature, stable infrastructure
- ✓ You prefer France/Poland data centers

### Choose Scaleway if:
- ✓ You want modern tooling and UI
- ✓ You're running smaller clusters (<10 nodes)
- ✓ You value developer experience
- ✓ You need latest Kubernetes features quickly
- ✓ IPv6 is important to you

### Choose UpCloud if:
- ✓ You need highest storage IOPS
- ✓ You want maximum flexibility
- ✓ You prefer Nordic/Baltic data centers
- ✓ You need a provider with strong Finnish/EU ownership

## Data Sovereignty Considerations

All three providers:
- ✓ EU-based companies
- ✓ Data centers exclusively in EU
- ✓ GDPR compliant by design
- ✓ No automatic data transfer to non-EU
- ✓ Subject to EU privacy laws

**Key Differences:**
- **OVH**: Largest European player, French company
- **Scaleway**: Part of Iliad Group (French)
- **UpCloud**: Finnish company, strong Nordic privacy culture

## Migration Between Providers

All providers support standard Kubernetes, making migration possible:

1. **Export workloads**: Use `kubectl`, Helm charts, or GitOps
2. **Backup data**: Use Velero or provider snapshots
3. **Recreate in new provider**: Deploy infrastructure with Terraform
4. **Restore data**: From backups or sync directly
5. **Update DNS**: Point to new load balancers

Estimated migration time: 1-3 days for production workloads

## Decision Matrix

| Priority | Recommended Provider |
|----------|---------------------|
| Lowest Cost | **OVH** (free control plane + monthly billing) |
| Best UI/UX | **Scaleway** |
| Most Regions | **OVH** |
| Highest Storage Performance | **UpCloud** |
| Fastest K8s Updates | **Scaleway** |
| Largest Instance Variety | **OVH** |
| Nordic Preference | **UpCloud** |
| Best for Startups | **Scaleway** |
| Best for Enterprises | **OVH** |

## Getting Started

### OVH
```bash
# Use movetoeu.cloud Terraform
git clone <repo>
cd infrastructure/ovh
./quickstart.sh
```

### Scaleway
```bash
# Coming soon to movetoeu.cloud
```

### UpCloud
```bash
# Coming soon to movetoeu.cloud
```

## Support & Community

| Provider | Support Tier | Community |
|----------|-------------|-----------|
| OVH | 24/7 ticketing, paid premium support | Large, active forums |
| Scaleway | 24/7 ticketing, dedicated support plans | Slack, active docs |
| UpCloud | 24/7 support included | Discord, responsive |

## Compliance Certifications

All providers maintain:
- ISO 27001 (Information Security)
- SOC 2 Type II
- GDPR compliance
- PCI DSS (for payment data)

OVH additionally has:
- HDS (French healthcare data)
- SecNumCloud (French government)

## Final Recommendation

**For movetoeu.cloud, we recommend starting with OVH** because:

1. **Free control plane** = significant cost savings at scale
2. **Monthly billing** = 30% discount on stable workloads
3. **Most regions** = best coverage across EU
4. **Mature platform** = proven reliability
5. **Best value** = lowest total cost of ownership

However, all three are excellent EU-sovereign choices. The Terraform modules in this repository make it easy to deploy on any provider or even run multi-cloud for redundancy.
