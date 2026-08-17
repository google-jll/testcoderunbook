# GCP Terraform Example: Palo Alto Deployment (`palodeploy`)

This example demonstrates how to deploy a high-availability **Palo Alto Networks / Panorama** firewall infrastructure on GCP utilizing standard foundation Terraform modules (`modules/vpc`, `modules/firewall-policy`, `modules/compute-vm/instance_template`, `modules/compute-vm/mig`, and `modules/iam/service-account`).

## Architecture & Overview

The configuration provisions three distinct isolated VPC networks, Panorama instances in High Availability across 2 zones via Regional MIG, and VM-Series Firewalls across 2 zones via Regional MIG connected across management, untrust, and trust subnets:

1. **VPC Networks & Subnets (`modules/vpc`)**:
   - **Management VPC (`fw-mgmt-vpc`)**: Subnet `10.10.10.0/24` for VM management and Panorama communication.
   - **Trust VPC (`fw-trust-vpc`)**: Subnet `10.20.10.0/24` for internal workload traffic.
   - **Untrust VPC (`fw-untrust-vpc`)**: Subnet `10.30.10.0/24` for external/internet ingress and egress traffic.
   - **Policy Enforcement Order**: `network_firewall_policy_enforcement_order` is set to `"BEFORE_CLASSIC_FIREWALL"` across all VPC networks so network firewall policies are evaluated prior to classic firewall rules.

2. **Network Firewall Policy (`modules/firewall-policy`)**:
   - Network Firewall Policy associated with Management VPC allowing SSH (`22`), HTTPS (`443`), and Panorama ports (`3978`, `28443`).

3. **Identity & Access Management (`modules/iam/service-account`)**:
   - Service account for Panorama instances (`panorama-sa`).
   - Service account for VM-Series Firewall instances (`vmseries-sa`).

4. **Managed Instance Groups & Dynamic Instance IP Querying (`modules/compute-vm/instance_template` & `modules/compute-vm/mig`)**:
   - **Panorama Regional MIG (`panorama-mig`)**: Spun up across 2 zones (`us-central1-a`, `us-central1-b`) in the region using `modules/compute-vm/mig`.
   - **Panorama Instance Querying (`data.google_compute_region_instance_group` & `data.google_compute_instance`)**: Queries `panorama-mig` instance group to fetch GCE instance self-links and private IP addresses.
   - **VM-Series Firewall Regional MIG (`pa-fw-mig`)**: Spun up across 2 zones in the region using `modules/compute-vm/mig`. Multi-NIC compute templates connected to all 3 VPC networks (`nic0`: Management, `nic1`: Untrust, `nic2`: Trust).
   - Bootstrapped via custom metadata (`init-cfg-txt`) dynamically passing the Panorama GCE instance IP addresses (`panorama-server=${data.google_compute_instance.panorama_instances[0].network_interface[0].network_ip}`).

> [!NOTE]
> **Base Windows Images**: By default, `panorama_image_family` and `fw_image_family` use standard base Windows Server images (`windows-cloud/windows-2022`). This avoids deployment errors caused by missing GCP Marketplace image entitlements or licenses. You can override these variables with Palo Alto BYOL image parameters if your GCP project has active Marketplace subscriptions.

---

## Modules Called

- **`module.mgmt_vpc`**: Source `../../modules/vpc` (Management VPC with `BEFORE_CLASSIC_FIREWALL`)
- **`module.trust_vpc`**: Source `../../modules/vpc` (Trust VPC with `BEFORE_CLASSIC_FIREWALL`)
- **`module.untrust_vpc`**: Source `../../modules/vpc` (Untrust VPC with `BEFORE_CLASSIC_FIREWALL`)
- **`module.mgmt_firewall_policy`**: Source `../../modules/firewall-policy` (Management Network Firewall Policy)
- **`module.panorama_sa`**: Source `../../modules/iam/service-account` (Panorama Service Account)
- **`module.panorama_template`**: Source `../../modules/compute-vm/instance_template` (Panorama Instance Template)
- **`module.panorama_mig`**: Source `../../modules/compute-vm/mig` (Panorama Regional MIG across 2 zones)
- **`module.fw_sa`**: Source `../../modules/iam/service-account` (VM-Series Firewall Service Account)
- **`module.fw_template`**: Source `../../modules/compute-vm/instance_template` (VM-Series Firewall Instance Template)
- **`module.fw_mig`**: Source `../../modules/compute-vm/mig` (VM-Series Firewall Regional MIG across 2 zones)

---

## Prerequisites

- **Terraform**: `>= 1.5.0`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with sufficient IAM permissions on the target project.
- **Enabled APIs**: `compute.googleapis.com`, `iam.googleapis.com`.

---

## Quick Start & Usage

```bash
# 1. Navigate to the example directory
cd examples/palodeploy

# 2. Copy the sample variable configuration file
cp terraform.tfvars.example terraform.tfvars

# 3. Edit terraform.tfvars with your GCP project ID and credentials
#    Set project_id and panos_auth_key

# 4. Initialize Terraform modules and provider plugins
terraform init

# 5. Generate and review execution plan
terraform plan

# 6. Apply infrastructure changes
terraform apply
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP Project ID | `string` | n/a | **Yes** |
| `region` | GCP region for deployment | `string` | `"us-central1"` | No |
| `zones` | List of 2 GCP zones in region for instance distribution | `list(string)` | `["us-central1-a", "us-central1-b"]` | No |
| `panos_auth_key` | Panorama VM Auth Key used to register firewalls | `string` | n/a | **Yes** |
| `panorama_image_family` | Image family for Panorama instances | `string` | `"windows-2022"` | No |
| `panorama_image_project` | Image project for Panorama instances | `string` | `"windows-cloud"` | No |
| `fw_image_family` | Image family for VM-Series Firewall instances | `string` | `"windows-2022"` | No |
| `fw_image_project` | Image project for VM-Series Firewall instances | `string` | `"windows-cloud"` | No |
| `panorama_machine_type` | Machine type for Panorama instances | `string` | `"n2-standard-16"` | No |
| `fw_machine_type` | Machine type for VM-Series Firewall instances | `string` | `"n2-standard-4"` | No |

---

## Outputs

| Name | Description |
|------|-------------|
| `panorama_instances_ips` | Private IPs of GCE instances created in Panorama Regional MIG |
| `panorama_mig_self_link` | Self-link of Panorama Regional Managed Instance Group |
| `panorama_instance_group` | Instance group URL of Panorama Regional Managed Instance Group |
| `fw_mig_self_link` | Self-link of VM-Series Firewall Regional Managed Instance Group |
| `fw_instance_group` | Instance group URL of VM-Series Firewall Regional Managed Instance Group |
| `mgmt_vpc_id` | Management VPC Network ID |
| `trust_vpc_id` | Trust VPC Network ID |
| `untrust_vpc_id` | Untrust VPC Network ID |
| `mgmt_firewall_policy_id` | Management Network Firewall Policy ID |
