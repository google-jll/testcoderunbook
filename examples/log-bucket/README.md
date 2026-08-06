# Cloud Logging Bucket + Log Scope Example

This example provisions a **custom Cloud Logging bucket** with **Log Analytics** enabled and a **log scope** that spans one or more projects, using the [`log-bucket`](../../modules/log-bucket) module.

## What it creates

- A log bucket (`google_logging_project_bucket_config`) in `var.project_id`, with the given `retention_days`, Log Analytics on, and a sample field index.
- A log scope (`google_logging_log_scope`) named `var.scope_name` covering `var.scope_resource_names` — the set of projects/views searched together in Logs Explorer and Log Analytics.
- A log sink in each `var.sink_source_projects` routing that project's logs into the bucket, with an example **`sink_filter`** (`severity >= "WARNING" AND NOT logName:"cloudaudit.googleapis.com%2Fdata_access"`) so only WARNING+ entries — minus Data Access audit noise — are forwarded.

## Usage

```bash
terraform init
terraform plan \
  -var 'project_id=my-project' \
  -var 'scope_resource_names=["projects/my-project"]'
terraform apply \
  -var 'project_id=my-project' \
  -var 'scope_resource_names=["projects/my-project"]'
```

Enabling Log Analytics is **irreversible** on a bucket — plan accordingly.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | Project that owns the bucket and scope. | `string` | n/a | yes |
| `region` | Default provider region. | `string` | `"us-west1"` | no |
| `bucket_id` | Name of the log bucket. | `string` | `"example-logs"` | no |
| `location` | Bucket location (`"global"` or a region). | `string` | `"global"` | no |
| `retention_days` | Days to retain log entries. | `number` | `30` | no |
| `scope_name` | Short name of the log scope. | `string` | `"example-scope"` | no |
| `scope_resource_names` | Projects/views the scope spans. | `list(string)` | `[]` | no |
| `sink_source_projects` | Projects whose logs are routed into the bucket (filtered). | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | Full resource name of the log bucket. |
| `scope_id` | Full resource id of the log scope. |
