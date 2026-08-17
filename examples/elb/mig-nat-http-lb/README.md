# GCP Terraform Example: Elb - Mig Nat Http Lb

This example demonstrates how to deploy and manage infrastructure for **Elb - Mig Nat Http Lb** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.cloud-nat`**: Source `"../../../modules/cloud-nat"`
- **`module.mig_template`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.mig`**: Source `"../../../modules/compute-vm/mig"`
- **`module.gce-lb-http`**: Source `"../../../modules/elb/elb"`

### Resources Provisioned Directly
- `google_compute_network.default`
- `google_compute_subnetwork.default`
- `google_compute_router.default`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/elb/mig-nat-http-lb

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project = "YOUR_PROJECT"
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
| `project` | n/a | `string` | n/a | Yes |
| `network_name` | n/a | `any` | `"tf-lb-http-mig-nat"` | No |
| `region` | n/a | `any` | `"us-west1"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `backend_services` | n/a |
| `load-balancer-ip` | n/a |
| `load-balancer-ipv6` | The IPv6 address of the load-balancer, if enabled; else \ |
