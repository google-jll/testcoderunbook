# GCP Network Firewall Policy & Secure Tags Comprehensive Architecture

This example demonstrates how to provision and enforce **Google Cloud Network Firewall Policies** using the [`modules/firewall-policy`](../../modules/firewall-policy) module in conjunction with **Google Cloud Secure Tags** (Resource Manager Tags) using the [`modules/secure-tags`](../../modules/secure-tags) module.

It covers a comprehensive matrix of **use cases**, **actions**, **targets**, **target types**, **directions**, **source filters**, **destinations**, and optional **NSI Intercept / Palo Alto steering (`security_profile_group` & `create_profile_rules`)**.

---

## Supported Use Cases Matrix

| # | Use Case Name | Direction | Action | Target Type | Source Filter (`match.src_*`) | Destination Filter (`match.dest_*`) | Layer 4 Protocol & Ports | Security / Operational Intent |
|---|---------------|:---------:|:------:|:-----------:|:-----------------------------:|:-----------------------------------:|:------------------------:|-------------------------------|
| **1** | **Apply to All Baseline Egress** | `EGRESS` | `allow` | **Apply to All** (no target) | N/A (all VMs in VPC) | `dest_ip_ranges = ["10.200.0.0/16"]` | TCP 80, 443 | Permits all workloads across VPC to reach internal corporate SD-WAN. |
| **2** | **Service Account Target Egress** | `EGRESS` | `allow` | **Service Account** (`app1-workload-sa`) | N/A | `dest_ip_ranges = ["0.0.0.0/0"]` | TCP 443 | Permits internet egress only for workloads running under designated service account identity. |
| **3** | **Target Secure Tag Egress (App1)** | `EGRESS` | `allow` | **Secure Tag** (`app-tier/app1`) | N/A | `dest_ip_ranges = ["0.0.0.0/0"]` | TCP 443 | Allows internet access strictly for VMs bound to Tag `app1`. Cannot be spoofed from within guest OS. |
| **4** | **Target Secure Tag Egress (App2)** | `EGRESS` | `allow` | **Secure Tag** (`app-tier/app2`) | N/A | `dest_ip_ranges = ["0.0.0.0/0"]` | TCP 443 | Allows internet access strictly for VMs bound to Tag `app2`. |
| **5** | **Zero-Trust Micro-segmentation** | `INGRESS` | `allow` | **Secure Tag** (`app-tier/database`) | `src_secure_tags = ["app-tier/app1"]` | N/A | TCP 5432 (Postgres) | Dynamic cross-tier access: Only App1 tagged instances can access Database instances. Decoupled from IP addresses. |
| **6** | **Explicit Inter-App Isolation** | `INGRESS` | `deny` | **Secure Tag** (`app-tier/app2`) | `src_secure_tags = ["app-tier/app1"]` | N/A | `all` | Strict boundary enforcement: Prevents direct lateral movement between App1 and App2 tiers. |
| **7** | **Admin Ingress via Google Cloud IAP** | `INGRESS` | `allow` | **Secure Tag** (`app-tier/app1`, `app2`) | `src_ip_ranges = ["35.235.240.0/20"]` | N/A | TCP 22 (SSH) | Restricts administrative SSH access exclusively through Identity-Aware Proxy (IAP). |
| **8** | **Rule Chaining (`goto_next`)** | `INGRESS` | `goto_next` | **Apply to All** | `src_ip_ranges = ["10.250.0.0/16"]` | N/A | TCP 443 | Evaluation bypass: Hands off management traffic to lower-priority rules or delegated policies. |
| **9** | **Optional NSI Intercept Steering** | `INGRESS`/`EGRESS` | `apply_security_profile_group` | **Apply to All** | `src_ip_ranges` | `dest_ip_ranges` | `all` | Steers traffic through Palo Alto / NSI Producer deployment group via `security_profile_group` (set `create_profile_rules = true`). |

---

## Architectural Diagram

```
                                    +----------------------------------------------------+
                                    |                 GCP VPC Network                    |
                                    |             (10.10.0.0/24 Subnet)                  |
                                    +----------------------------------------------------+
                                               |                              |
                                               v                              v
                                  +------------------------+     +------------------------+
                                  |    VM-App1 Workload    |     |    VM-App2 Workload    |
                                  |   (App1 Service Acct)  |     |   (App2 Service Acct)  |
                                  +------------------------+     +------------------------+
                                               |                              |
                                        [Tag Binding]                  [Tag Binding]
                                               |                              |
                                               v                              v
                                  +------------------------+     +------------------------+
                                  | Tag: app-tier/app1     |     | Tag: app-tier/app2     |
                                  +------------------------+     +------------------------+
                                               \                              /
                                                \                            /
                         +-----------------------------------------------------------------------+
                         |                    Network Firewall Policy Rules                      |
                         |-----------------------------------------------------------------------|
                         |  (Optional) NSI Intercept   -> Steer traffic to security_profile_group|
                         |                                (when create_profile_rules = true)     |
                         |  1000: "Apply to All"       -> Allow baseline Egress to SD-WAN        |
                         |  1010: "Service Account"    -> Allow Egress for app1-workload-sa      |
                         |  1020: "Target Secure Tag"  -> Allow HTTPS Egress only for App1 VMs   |
                         |  1030: "Target Secure Tag"  -> Allow HTTPS Egress only for App2 VMs   |
                         |  1040: "Micro-segmentation" -> Allow App1 -> Database (port 5432)     |
                         |  1050: "Explicit Isolation" -> Deny direct traffic App1 -> App2       |
                         |  1060: "Admin Access"       -> Allow SSH from Google Cloud IAP range  |
                         |  1070: "Rule Chaining"      -> goto_next for management traffic       |
                         +-----------------------------------------------------------------------+
```

---

## Modules Utilized

1. **[`modules/secure-tags`](../../modules/secure-tags)**:
   - Provisions `app-tier` (`app1`, `app2`, `database`) and `environment` (`nonprod`, `prod`) tag keys and tag values.
   - Automatically handles Organization or Project scope.
2. **[`modules/firewall-policy`](../../modules/firewall-policy)**:
   - Provisions the Network Firewall Policy and attaches it to the VPC network.
   - Generates all custom rules with full support for actions (`allow`, `deny`, `goto_next`, `apply_security_profile_group`), directions (`INGRESS`, `EGRESS`), target types (`target_secure_tags`, `target_service_accounts`, all workloads), match criteria (`src_secure_tags`, `src_ip_ranges`, `dest_ip_ranges`, protocols/ports), and optional NSI Intercept steering via `security_profile_group` & `create_profile_rules`.

---

## Deployment & Verification

### 1. Initialize and Apply
```bash
cp terraform.tfvars.example terraform.tfvars
# Update project_id in terraform.tfvars
terraform init
terraform plan
terraform apply
```

### 2. Verify Firewall Policy Rules via gcloud
```bash
gcloud compute network-firewall-policies rules list \
    --firewall-policy=fw-policy-secure-tags-demo \
    --project=YOUR_PROJECT_ID
```

### 3. Verify Tag Bindings on Compute Instances
```bash
gcloud resource-manager tags bindings list \
    --parent=//compute.googleapis.com/projects/YOUR_PROJECT_ID/zones/me-central2-a/instances/vm-app1-workload
```
