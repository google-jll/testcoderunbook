# GCP Terraform Module: Nsi Producer - Bootstrap

This module provisions and manages **Nsi Producer - Bootstrap** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_storage_bucket`** (1 instance): `this`
- **`google_storage_bucket_iam_member`** (1 instance): `member`
- **`google_storage_bucket_object`** (5 instances): `config_empty`, `content_empty`, `license_empty`, `software_empty`, `file`
- **`random_string`** (1 instance): `randomstring`

## Usage Example

```hcl
module "bootstrap" {
  source = "../../modules/nsi-producer/bootstrap"

  files = var.files
  location = var.location
  # name_prefix = "paloaltonetworks-firewall-bootstrap-"
  # bucket_name = null
  # service_account = null
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
| `location` | Location in which the GCS Bucket will be deployed. Available locations can be found under https://cloud.google.com/storage/docs/locations. | `string` | n/a | Yes |
| `bootstrap_files_dir` | Bootstrap file directory. If the variable has a value of `null` (default) - then it will not upload any other files other than the ones specified in the `files` variable.   More information can be found at https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-package. | `string` | `null` | No |
| `bucket_name` | Explicit, full bucket name. When set, the random suffix is NOT used (and no random_string is created) — use this to adopt/import an existing bootstrap bucket without renaming it. | `string` | `null` | No |
| `files` | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. For example `{\ | `map(string)` | `{}` | No |
| `folders` | List of folder paths that will be used to create dedicated boostrap package folder sets per firewall or firewall group (for example to distinguish configuration per region, per inbound/obew role, etc) within the created storage bucket.    A default value (empty list) will result in the creation of a single bootstrap package folder set in the bucket top-level directory. | `list(any)` | `[]` | No |
| `name_prefix` | Prefix of the name of Google Cloud Storage bucket, followed by 10 random characters. Ignored when bucket_name is set. | `string` | `"paloaltonetworks-firewall-bootstrap-"` | No |
| `service_account` | Optional IAM Service Account (just an email) that will be granted read-only access to this bucket | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `bucket` | n/a |
| `bucket_name` | n/a |
