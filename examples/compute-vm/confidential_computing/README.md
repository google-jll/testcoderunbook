# GCP Terraform Example: Compute Vm - Confidential Computing

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Confidential Computing** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.kms`**: Source `"terraform-google-modules/kms/google"`
- **`module.instance_template`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.compute_instance`**: Source `"../../../modules/compute-vm/compute_instance"`
- **`module.confidential-computing-org-policy`**: Source `"terraform-google-modules/org-policy/google"`
- **`module.enforce-cmek-org-policy`**: Source `"terraform-google-modules/org-policy/google"`
- **`module.restrict-cmek-cryptokey-projects-policy`**: Source `"terraform-google-modules/org-policy/google"`

### Resources Provisioned Directly
- `random_string.suffix`
- `google_service_account.default`
- `google_project_iam_member.service_account_roles`
- `google_kms_crypto_key_iam_binding.crypto_key`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/confidential_computing

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
subnetwork = "YOUR_SUBNETWORK"
keyring = "YOUR_KEYRING"
key = "YOUR_KEY"
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `key` | Key name. | `string` | n/a | Yes |
| `keyring` | Keyring name. | `string` | n/a | Yes |
| `project_id` | The Google Cloud project ID. | `string` | n/a | Yes |
| `subnetwork` | The subnetwork selflink to host the compute instances in. | `string` | n/a | Yes |
| `location` | Location for the resources (keyring, key, network, etc.). | `string` | `"us"` | No |
| `region` | The GCP region to create and test resources in. | `string` | `"us-central1"` | No |
| `service_account_roles` | Predefined roles for the Service account that will be created for the VM. Remember to follow principles of least privileges with Cloud IAM. | `list(string)` | `[]` | No |
| `suffix` | A suffix to be used as an identifier for resources. (e.g., suffix for KMS Key, Keyring). | `string` | `""` | No |
## Outputs

| Name | Description |
|------|-------------|
| `instance_self_link` | Self-link for compute instance. |
| `name` | Name of the instance templates. |
| `self_link` | Self-link to the instance template. |
| `suffix` | Suffix used as an identifier for resources. |
