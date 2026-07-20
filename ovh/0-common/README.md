# OVH Common - Project & Provider Setup

This workspace handles:
- OVH provider configuration
- Public Cloud project setup
- API credentials management

## Prerequisites

1. Create an OVH account: https://www.ovh.com/auth/signup/
2. Create API credentials: https://api.ovh.com/createToken/
   - Required rights: GET/POST/PUT/DELETE on `/cloud/*`
   - Also add: GET/POST/PUT/DELETE on `/v2/publicCloud/*` — the newer Public Cloud
     instance/SSH key resources used by the `3-compute` workspace
     (`ovh_cloud_project_instance`, `ovh_cloud_ssh_key`) call this v2 API, which is a
     separate ACL namespace from `/cloud/*`. Omitting it causes a 403
     `Client::Forbidden: "This call has not been granted"` on those resources even
     though other cloud calls work fine.
3. Create a Public Cloud project in the OVH Control Panel

## Setup

1. Copy the example configuration:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values:
```hcl
ovh_application_key    = "your_app_key"
ovh_application_secret = "your_app_secret"
ovh_consumer_key      = "your_consumer_key"
ovh_project_id        = "your_project_id"
```

3. Initialize and apply:
```bash
terraform init
terraform apply
```

## Outputs

- `project_id` - Public Cloud project ID (used by network and kubernetes workspaces)
- `project_description` - Project description

## Environment Variables (Alternative to tfvars)

You can also use environment variables instead of terraform.tfvars:

```bash
export OVH_ENDPOINT="ovh-eu"
export OVH_APPLICATION_KEY="xxx"
export OVH_APPLICATION_SECRET="xxx"
export OVH_CONSUMER_KEY="xxx"
export OVH_CLOUD_PROJECT_SERVICE="your_project_id"
```
