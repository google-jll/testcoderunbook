# GCP Organization Policy Terraform Example

This example demonstrates how to enable, disable, and configure **Google Cloud Organization Policies** using the [`modules/org-policy`](../../modules/org-policy) foundation module.

---

## Features & Scenarios Demonstrated

1. **Enabling Boolean Constraints**:
   - `compute.requireShieldedVm`: Enforces that all Compute Engine VMs must use Shielded VM features.
   - `compute.requireOsLogin`: Enforces OS Login for SSH access across instances.
2. **Disabling / Relaxing Boolean Constraints**:
   - `iam.disableServiceAccountKeyCreation`: Explicitly sets `enforce = false` to allow service account key creation when required.
3. **Configuring List Constraints**:
   - `gcp.resourceLocations`: Restricts deployment locations strictly to permitted geographic regions (`in:us-locations`, `in:eu-locations`).
   - `compute.vmExternalIpAccess`: Blocks external IP address assignment (`deny_all = true`) to enforce private workloads.

---

## Architecture & Resources Created

### Modules Called
- **`module.org_policy`**: Source `"../../modules/org-policy"`

### Resources Provisioned
- `google_org_policy_policy.boolean_policies["compute.requireShieldedVm"]`
- `google_org_policy_policy.boolean_policies["compute.requireOsLogin"]`
- `google_org_policy_policy.boolean_policies["iam.disableServiceAccountKeyCreation"]`
- `google_org_policy_policy.list_policies["gcp.resourceLocations"]`
- `google_org_policy_policy.list_policies["compute.vmExternalIpAccess"]`

---

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with `roles/orgpolicy.policyAdmin` on the target Project/Organization.
- **Required API**: Ensure `orgpolicy.googleapis.com` is enabled in your project.

---

## Usage & Execution Steps

```bash
# 1. Navigate to this directory
cd examples/org-policy

# 2. Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Update project_id in terraform.tfvars

# 3. Initialize Terraform plugins
terraform init

# 4. Review execution plan
terraform plan

# 5. Apply configuration
terraform apply

# 6. Clean up resources when done
terraform destroy
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The GCP project ID to apply organization policies to. | `string` | n/a | Yes |
| `allowed_regions` | List of GCP regional locations permitted by the resource locations policy. | `list(string)` | `["in:us-locations", "in:eu-locations"]` | No |
| `parent` | Optional custom parent URI (e.g. 'organizations/1234567890' or 'folders/1234567890'). If omitted, defaults to 'projects/<project_id>'. | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `boolean_policy_ids` | Map of created Boolean policy IDs. |
| `list_policy_ids` | Map of created List policy IDs. |
