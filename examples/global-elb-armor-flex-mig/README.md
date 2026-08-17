# Global External Load Balancer with Cloud Armor, Flex MIG, Secure Tags & NSI Consumer Example

This example demonstrates how to deploy an end-to-end production architecture featuring a **Global External HTTP Load Balancer (ELB)**, **Cloud Armor IP Allowlist Security Policy**, **Secure Tags**, **Network Service Integration (NSI Consumer)** connected to Palo Alto Next-Gen Firewalls (`testjll-panw-dg` in `jllnetworkhub`), and an **Autoscaled Managed Instance Group (MIG)** with **Flexible Machine Types (Flex MIG)** option using foundation modules.

---

## Architecture Overview

```
                      [ Internet Traffic ]
                                │
                                ▼
         [ Global External HTTP Load Balancer (ELB) ]
                         (modules/elb/elb)
                                │
            (Protected by Cloud Armor Security Policy)
                      (modules/cloud-armor)
            ├─ Priority 100: ALLOW Whitelisted IP Ranges (allowed_ip_ranges)
            └─ Priority 2147483647: DENY (HTTP 403) All Other IPs
                                │
                                ▼
         [ Backend Service: HTTP Port 80 Health-Checked ]
                                │
                                ▼
         [ Network Service Integration (NSI Consumer) ]
                    (modules/nsi-consumer)
      Intercepts traffic (allowed_ip_ranges + LB Probes) to Palo Alto Producer:
      projects/jllnetworkhub/locations/global/interceptDeploymentGroups/testjll-panw-dg
                                │
                                ▼
       [ Network Firewall Policy (Managed by NSI Consumer) ]
            ├─ Intercept Rules: Steer inspect_ranges to PANW Deployment Group
            ├─ Rule 999:  ALLOW Whitelisted IPs (allowed_ip_ranges) -> Secure Tag
            ├─ Rule 1000: ALLOW Health Checks (130.211.0.0/22 & 35.191.0.0/16) -> Secure Tag
            └─ Rule 1001: ALLOW IAP SSH (35.235.240.0/20) -> Secure Tag
                                │
                                ▼
          [ Regional Managed Instance Group (Web MIG) ]
                    (modules/compute-vm/mig)
     (Flex MIG: n1-standard-1 / n2-standard-2 / e2-standard-2)
          (Tagged with Secure Tag: environment/web-mig-node)
                    (modules/secure-tags)
                                │
                                ▼
       [ Private Subnet + Cloud NAT Egress (No Public IPs) ]
       (modules/vpc, modules/cloud-router, modules/cloud-nat)
```

---

## Key Features & Components Demonstrated

1. **VPC Network & Subnetwork (`modules/vpc`)**:
   - Provisions a dedicated VPC network (`elb-flex-mig-vpc`) and private subnet (`10.10.10.0/24`) with Private Google Access enabled.
2. **Cloud Router & Cloud NAT (`modules/cloud-router` & `modules/cloud-nat`)**:
   - Provides outbound NAT internet access for private MIG instances to perform system updates (`apt-get install nginx`) without exposing public IP addresses.
3. **Secure Tags (`modules/secure-tags`)**:
   - Provisions IAM-governed Secure Tag Key (`environment`) and Tag Value (`web-mig-node`).
   - Attached directly to the Instance Template via `resource_manager_tags`, ensuring every GCE VM instance launched by the MIG / Flex MIG automatically inherits the tag for zero-trust firewall policy targeting.
4. **Network Service Integration Consumer (`modules/nsi-consumer`)**:
   - Connects the consumer VPC network to the Palo Alto NSI Producer Deployment Group (`projects/jllnetworkhub/locations/global/interceptDeploymentGroups/testjll-panw-dg`).
   - Creates Intercept Endpoint Group, Endpoint Group Association, Security Profile, Security Profile Group, and manages the Global Network Firewall Policy.
   - **`inspect_ranges`**: Set to `concat(var.allowed_ip_ranges, ["130.211.0.0/22", "35.191.0.0/16"])` so traffic from whitelisted client IPs and Load Balancer proxies is intercepted and inspected by Palo Alto firewalls.
   - **Custom Rules**: Passes custom rules targeting instances bound with `target_secure_tags = [module.secure_tags.values["environment/web-mig-node"]]`:
     - **Rule 999**: Allows whitelisted source IPs (`allowed_ip_ranges`) on HTTP port 80.
     - **Rule 1000**: Allows GCP Global Load Balancer probes (`130.211.0.0/22` and `35.191.0.0/16`) on HTTP port 80.
     - **Rule 1001**: Allows Identity-Aware Proxy SSH (`35.235.240.0/20`) on TCP port 22.
   - **Notice**: Standalone `module "firewall_policy"` in `main.tf` is skipped because `modules/nsi-consumer` creates and manages the Network Firewall Policy internally.
5. **Cloud Armor Security Policy (`modules/cloud-armor`)**:
   - Creates a Cloud Armor security policy (`elb-cloud-armor-allowlist`).
   - Priority 100 allow rule permits traffic from specified IPv4 CIDR blocks (`allowed_ip_ranges`).
   - Default lowest priority rule drops all unwhitelisted internet traffic with HTTP 403 Forbidden.
6. **Instance Template (`modules/compute-vm/instance_template`)**:
   - Configures an NGINX web server workload with startup script and Secure Tags.
7. **Managed Instance Group with Flex MIG Option (`modules/compute-vm/mig`)**:
   - **Flexible MIG Option (`enable_flex_mig = true`)**: Configures `instance_selections` to allow Compute Engine to provision instances across multiple machine types (`n1-standard-1` rank 1, `n2-standard-2` rank 2, `e2-standard-2` rank 3) based on availability.
   - **Standard MIG Option (`enable_flex_mig = false`)**: Falls back to standard uniform instance shape.
   - **Auto Healing**: HTTP health check on port 80 (`/`).
   - **Autoscaling**: Automatically scales between `min_replicas` (2) and `max_replicas` (5) based on 70% CPU utilization.
8. **Global External Load Balancer (`modules/elb/elb`)**:
   - Provisions global forwarding rules, target HTTP proxy, global URL map, and backend service directly linked to the Cloud Armor security policy.

---

## Prerequisites

- **Terraform**: `>= 1.3`
- **GCP Credentials**: Authenticated with `gcloud auth application-default login` having `roles/compute.admin`, `roles/networksecurity.admin`, `roles/resourcemanager.tagAdmin`, and `roles/iam.serviceAccountUser` on the target project.
- **Organization Permissions**: Organization-level permissions for creating `google_network_security_security_profile` and `google_network_security_security_profile_group`.
- **Enabled GCP APIs**: Ensure `compute.googleapis.com`, `networksecurity.googleapis.com`, and `tagmanager.googleapis.com` are enabled in your project.

---

## Usage & Execution Steps

```bash
# 1. Navigate to this example directory
cd foundation-terraform/examples/global-elb-armor-flex-mig

# 2. Copy the sample variables file
cp terraform.tfvars.example terraform.tfvars

# 3. Edit terraform.tfvars with your GCP project ID, Org ID, and whitelisted IP ranges
# project_id        = "my-gcp-project-id"
# org_id            = "123456789012"
# producer_dg       = "projects/jllnetworkhub/locations/global/interceptDeploymentGroups/testjll-panw-dg"
# allowed_ip_ranges = ["203.0.113.0/24", "1.2.3.4/32"]
# enable_flex_mig   = true

# 4. Initialize Terraform plugins
terraform init

# 5. Review the execution plan
terraform plan

# 6. Apply the infrastructure
terraform apply

# 7. Test access:
# Traffic from allowed_ip_ranges will be intercepted by Palo Alto NSI and reach the GCE instances with "200 OK"
# Traffic from unallowed IPs will be blocked at Cloud Armor level with "403 Forbidden"
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `org_id` | The GCP organization ID (Security profiles/groups are organization-scoped). | `string` | n/a | Yes |
| `project_id` | The GCP project ID where consumer resources will be deployed. | `string` | n/a | Yes |
| `allowed_ip_ranges` | List of whitelisted IPv4 CIDR blocks allowed to access the Load Balancer via Cloud Armor. | `list(string)` | `["203.0.113.0/24", "198.51.100.5/32"] # Example trusted IP ranges` | No |
| `cloud_armor_policy_name` | Name of the Cloud Armor security policy. | `string` | `"elb-cloud-armor-allowlist"` | No |
| `default_machine_type` | Default machine type for the compute instance template. | `string` | `"n1-standard-1"` | No |
| `elb_name` | Name of the Global External Load Balancer. | `string` | `"global-web-elb"` | No |
| `enable_flex_mig` | Whether to deploy a Flexible Managed Instance Group (Flex MIG) using multiple instance selections/machine types. | `bool` | `true` | No |
| `flex_instance_selections` | Map of flexible instance selections (machine types & ranks) for Flex MIG. | `map(object({ machine_types = list(string) rank = number }))` | `{ "selection-n1-standard-1" = { machine_types = ["n1-standard-1"] rank = 1 } "selection-n2-standard-2" = { machine_types = ["n2-standard-2"] rank = 2 } "selection-e2-standard-2" = { machine_types = ["e2-standard-2"] rank = 3 } }` | No |
| `max_replicas` | Maximum number of instances in the MIG autoscaler. | `number` | `5` | No |
| `mig_name` | Base name and hostname for the Managed Instance Group. | `string` | `"web-app-mig"` | No |
| `min_replicas` | Minimum number of instances in the MIG autoscaler. | `number` | `2` | No |
| `network_name` | Name of the VPC network. | `string` | `"elb-flex-mig-vpc"` | No |
| `producer_dg` | The producer's intercept deployment group URI (Palo Alto NSI producer). | `string` | `"projects/jllnetworkhub/locations/global/interceptDeploymentGroups/testjll-panw-dg"` | No |
| `region` | The GCP region for regional resources (subnets, MIG, Cloud Router, Cloud NAT). | `string` | `"us-central1"` | No |
| `subnet_cidr` | IP CIDR range for the subnetwork. | `string` | `"10.10.10.0/24"` | No |
| `subnet_name` | Name of the subnetwork. | `string` | `"web-mig-subnet"` | No |
| `tag_key_name` | Short name for the Secure Tag Key. | `string` | `"environment"` | No |
| `tag_value_name` | Short name for the Secure Tag Value. | `string` | `"web-mig-node"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `cloud_armor_policy_name` | Name of the Cloud Armor security policy. |
| `cloud_armor_policy_self_link` | Self-link URI of the Cloud Armor security policy. |
| `elb_external_ip` | The external IPv4 address assigned to the Global External Load Balancer forwarding rule. |
| `mig_instance_group` | URI of the Managed Instance Group. |
| `mig_self_link` | Self-link of the Managed Instance Group Manager. |
| `nsi_producer_dg` | Palo Alto NSI Producer Deployment Group URI linked to NSI Consumer. |
| `secure_tag_key_id` | Tag Key ID created for GCE instance classification. |
| `secure_tag_value_id` | Tag Value ID attached to MIG GCE instances. |
| `subnet_id` | ID of the created subnetwork. |
| `vpc_network_name` | Name of the created VPC network. |
