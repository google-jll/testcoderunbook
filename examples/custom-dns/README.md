# GCP Terraform Example: Custom Dns

This example demonstrates how to deploy and manage infrastructure for **Custom Dns** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.gcp_dns_infrastructure`**: Source `"../../modules/custom-dns"`

### Resources
- **`data.google_compute_network.platform_vpc`**: Looks up the existing dedicated AD / platform VPC.
- **`data.google_compute_network.app_spoke_vpc`**: Looks up each existing app-spoke (workload) VPC.

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.
- **Existing VPCs**: The networks named in `platform_vpc_name` and `app_spoke_vpc_names` must already exist in `project_id`.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/custom-dns

# 2. Create a terraform.tfvars from the sample and edit it for your environment
cp terraform.tfvars.example terraform.tfvars

# 3. Initialize Terraform plugins and backend
terraform init

# 4. Generate and review execution plan
terraform plan

# 5. Apply infrastructure changes
terraform apply

# 6. Destroy provisioned resources (when finished testing)
terraform destroy
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `platform_vpc_name` | Name of the existing dedicated AD / platform VPC that hosts the inbound endpoint. | `string` | n/a | Yes |
| `project_id` | The GCP project that owns the DNS resources and the referenced VPCs. | `string` | n/a | Yes |
| `app_spoke_vpc_names` | Names of existing app-spoke (workload) VPCs to authorize the private/forwarding zones on. | `list(string)` | `[]` | No |
| `enable_google_apis_psc_dns` | Create private zones for googleapis.com and p.googleapis.com pointing at the PGA/PSC VIPs. | `bool` | `true` | No |
| `enable_inbound_endpoint` | Create an inbound DNS endpoint policy on the platform VPC so on-prem AD can resolve Cloud DNS records. | `bool` | `true` | No |
| `forwarding_zones` | Map of outbound forwarding zones (Cloud DNS -> on-prem/AD DNS servers). | `map(object({ dns_name = string description = optional(string, "Forwarding to AD DNS") target_name_servers = list(string) }))` | `{}` | No |
| `google_apis_vips` | IP addresses the googleapis.com / p.googleapis.com A records resolve to (restricted VIPs by default). | `list(string)` | `[ "199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7", ]` | No |
| `inbound_policy_name` | Name of the inbound DNS policy. | `string` | `"dns-inbound-policy"` | No |
| `private_zones` | Map of custom private DNS zones to create. Each record's `name` is the FQDN; omit it to default to the zone's dns_name (apex). | `map(object({ dns_name = string description = optional(string, "Managed by Terraform") records = optional(map(object({ name = optional(string) type = string ttl = number records = list(string) })), {}) }))` | `{}` | No |
| `region` | Default provider region (Cloud DNS itself is global). | `string` | `"us-central1"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `forwarding_zone_names` | Map of created forwarding DNS zone names. |
| `inbound_endpoint_guidance` | How to find the allocated inbound endpoint IPs for AD conditional forwarders. |
| `inbound_policy_id` | The ID of the inbound DNS policy (null if disabled). |
| `private_zone_names` | Map of created private DNS zone names (includes the googleapis PSC/PGA zones when enabled). |
