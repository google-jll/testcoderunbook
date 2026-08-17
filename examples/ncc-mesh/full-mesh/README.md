# GCP Terraform Example: NCC Mesh - Full Mesh

This example demonstrates how to deploy a complete **Network Connectivity Center (NCC) Mesh Hub with initial VPC spokes** using standard foundation Terraform modules.

In a Mesh topology, every spoke attached to the hub has full any-to-any connectivity with every other spoke through the implicit `default` group.

---

## Architecture & Resources Created

### Modules Called
- **`module.spoke_a_vpc`**: Source `"../../../modules/network-foundation"`
- **`module.spoke_b_vpc`**: Source `"../../../modules/network-foundation"`
- **`module.spoke_c_vpc`**: Source `"../../../modules/network-foundation"`
- **`module.ncc`**: Source `"../../../modules/ncc-mesh"` (Hub created with `create_hub = true`)

---

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (`networkconnectivity.googleapis.com`, `compute.googleapis.com`) are enabled in your project.

---

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/ncc-mesh/full-mesh

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id   = "YOUR_PROJECT_ID"
ncc_hub_name = "example-mesh-hub"
EOF

# 3. Initialize Terraform plugins and backend
terraform init

# 4. Generate and review execution plan
terraform plan

# 5. Apply infrastructure changes
terraform apply

# 6. Destroy provisioned resources (when finished testing)
terraform destroy
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The GCP project that holds the hub and spoke networks. | `string` | n/a | **Yes** |
| `ncc_hub_name` | Name of the NCC hub. | `string` | `"example-mesh-hub"` | No |
| `region` | The GCP region for the spoke VPC subnets. | `string` | `"us-central1"` | No |
| `auto_accept_projects` | Project IDs (or numbers) whose spokes are automatically accepted into the mesh hub's `default` group when attaching later. | `list(string)` | `[]` | No |

---

## Outputs

| Name | Description |
|------|-------------|
| `hub` | The NCC hub object. |
| `ncc_hub_id` | The full resource ID of the NCC hub. |
| `spokes` | All spoke objects, keyed by type/name. |
