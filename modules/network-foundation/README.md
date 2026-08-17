# GCP Terraform Module: Network Foundation

This module provisions and manages **Network Foundation** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_network`** (1 instance): `vpc`
- **`google_compute_route`** (1 instance): `default_internet_egress`
- **`google_compute_subnetwork`** (3 instances): `dmz_tier`, `app_tier`, `data_tier`

## Usage Example

```hcl
module "network_foundation" {
  source = "../../modules/network-foundation"

  project_id = var.project_id
  vpc_name = var.vpc_name
  environment = var.environment
  subnet_cidr_dmz = var.subnet_cidr_dmz
  subnet_cidr_app = var.subnet_cidr_app
  subnet_cidr_data = var.subnet_cidr_data
  # region = "us-west1" # Default to primary KSA region for residency compliance
  # enable_internet_egress_route = false
  # delete_default_internet_route = true
}
```

## Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.3` |
| **Google Cloud Provider** | `>= 5.0, < 8` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | The deployment lifecycle environment (e.g., dev, uat, prod). | `string` | n/a | Yes |
| `project_id` | The target GCP Project ID where the network foundation will be created. | `string` | n/a | Yes |
| `subnet_cidr_app` | CIDR range for the Application / Workload Subnet Tier. | `string` | n/a | Yes |
| `subnet_cidr_data` | CIDR range for the Database / Private PSC Endpoints Subnet Tier. | `string` | n/a | Yes |
| `subnet_cidr_dmz` | CIDR range for the DMZ / Load Balancer Proxy Subnet Tier. | `string` | n/a | Yes |
| `vpc_name` | The name of the Standalone VPC network. | `string` | n/a | Yes |
| `delete_default_internet_route` | If true, deletes the auto-created 0.0.0.0/0 default route via the default internet gateway. | `bool` | `true` | No |
| `enable_internet_egress_route` | Controls whether a route to the internet is natively exposed in this VPC. | `bool` | `false` | No |
| `region` | The regional boundary for the subnets and routing resources. | `string` | `"us-west1" # Default to primary KSA region for residency compliance` | No |
## Outputs

| Name | Description |
|------|-------------|
| `subnet_app_id` | The ID of the App subnet. |
| `subnet_app_name` | The name of the App subnet. |
| `subnet_data_id` | The ID of the Data subnet. |
| `subnet_data_name` | The name of the Data subnet. |
| `subnet_dmz_id` | The ID of the DMZ subnet. |
| `subnet_dmz_name` | The name of the DMZ subnet. |
| `vpc_id` | The URI of the created Standalone VPC. |
| `vpc_name` | The name of the VPC. |
| `vpc_self_link` | The self-link of the VPC, used for hub attachments. |
