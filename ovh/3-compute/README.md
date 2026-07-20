# OVH Compute - Standalone Instance

This workspace creates:
- A standalone Public Cloud instance (general-purpose host, not part of the Kubernetes cluster)
- An SSH key registered in the project from your existing local public key
- Optional attachment to the private network created in `1-network`, alongside a public IP

## Prerequisites

- Completed `0-common` workspace setup
- Completed `1-network` workspace setup (if `enable_private_network = true`)
- An existing local SSH keypair (defaults to `~/.ssh/movetoeu.cloud.pub`)

## Setup

1. If attaching to the private network, fetch its IDs:
```bash
cd ../1-network && terraform output
```
Copy `private_network_openstack_id` into `private_network_id` and `nodes_subnet_id` (or
`lb_subnet_id`) into `private_network_subnet_id` in `terraform.tfvars`.

2. Review `terraform.tfvars` — adjust `region`, `flavor_name`, `image_name`, and
   `ssh_public_key_path` as needed. Available flavors/images for your region can be checked
   with the OVH Control Panel or the `ovh_cloud_project_flavors` / `ovh_cloud_project_images`
   data sources used in `main.tf`.

3. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `instance_id` / `instance_name` / `instance_status`
- `instance_addresses` - all IPs (public and private) assigned to the instance
- `flavor_id` / `flavor_name` / `image_id` - resolved values actually used
- `ssh_key_name` - name of the SSH key registered in the project

## Connecting

```bash
terraform output instance_addresses
ssh -i ~/.ssh/movetoeu.cloud <user>@<public-ip-from-above>
```

The SSH login user depends on the image (e.g. `ubuntu` for Ubuntu images).

## Networking

- `enable_public_ip` (default `true`) attaches a public interface for direct internet access.
- `enable_private_network` (default `true`) attaches the instance to the private network/subnet
  from `1-network`, so it can reach the Kubernetes nodes and load balancers over vRack.
- Both can be enabled together (public + private NICs), or you can disable the public one to
  keep the instance reachable only through the private network and the `1-network` gateway.

## Notes

- `ovh_cloud_project_instance` and `ovh_cloud_ssh_key` use OVH's beta Public Cloud instance API.
- Billing: `hourly` bills per usage, `monthly` gives a discount for instances left running.
- Destroying this workspace only removes the instance and its SSH key; the network and
  Kubernetes cluster are untouched.
