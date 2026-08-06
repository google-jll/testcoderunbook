# Google Cloud Log Bucket + Log Scope Module

This module manages a **Cloud Logging bucket** (`google_logging_project_bucket_config`) and, optionally, a **log scope** (`google_logging_log_scope`) — the pairing you need to centralize log storage and then search across it.

The **bucket** is where log entries are stored: it sets the retention period, can turn on **Log Analytics** (BigQuery-backed SQL over your logs), and can be encrypted with a CMEK key. The **scope** is a saved set of projects and/or log views that Logs Explorer and Log Analytics query together — so a single search spans the hub project and every workload project at once.

---

## Features

- **Custom or well-known buckets** — create a new bucket, or adopt `_Default` / `_Required` in place by passing its `bucket_id`.
- **Retention & locking** — set `retention_days`, and `locked` to prevent the retention period from being reduced.
- **Log Analytics** — `enable_analytics` for SQL querying (irreversible once on).
- **CMEK** — encrypt the bucket with a customer-managed key via `kms_key_name`.
- **Field indexing** — `index_configs` to speed up queries against structured fields.
- **Optional log scope** — set `create_scope = true` and list `scope_resource_names` (projects and/or views, max 50 projects / 100 resources) to search them together.
- **Log routing (sinks)** — list `sink_source_projects` to create a sink in each project that routes its logs into this bucket. A **cross-project** sink gets a unique writer identity, and the module grants it `roles/logging.bucketWriter` on the bucket's project automatically. A sink for the **bucket's own project** needs no writer identity or grant (GCP routes it via the default logging identity), so the module skips both for that one. The Terraform identity needs `logging.sinks` permission in every source project.

---

## Usage

### Bucket only

```hcl
module "log_bucket" {
  source = "../../modules/log-bucket"

  project_id       = "my-project"
  bucket_id        = "app-logs"
  location         = "global"
  retention_days   = 90
  enable_analytics = true
}
```

### Bucket + a scope spanning several projects

```hcl
module "log_bucket" {
  source = "../../modules/log-bucket"

  project_id       = "jllnetworkhub"
  bucket_id        = "jll-network-logs"
  location         = "global"
  retention_days   = 30
  enable_analytics = true

  create_scope         = true
  scope_name           = "jll-network-scope"
  scope_description    = "Search hub + workload project logs together"
  scope_resource_names = [
    "projects/jllnetworkhub",
    "projects/jll-app1",
    "projects/jll-app2",
  ]

  # Route each project's logs into the bucket (creates a sink + bucketWriter grant per project).
  sink_source_projects = [
    "jllnetworkhub",
    "jll-app1",
    "jll-app2",
  ]
}
```

Verify with gcloud:

```bash
# The bucket
gcloud logging buckets describe jll-network-logs \
  --project=jllnetworkhub --location=global

# The scope
gcloud logging scopes describe jll-network-scope \
  --project=jllnetworkhub --location=global
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | Project that owns the bucket (and scope). | `string` | n/a | yes |
| `bucket_id` | Name of the log bucket, or a well-known id (`_Default`/`_Required`) to adopt. | `string` | n/a | yes |
| `location` | Bucket location: `"global"` or a supported region. | `string` | `"global"` | no |
| `retention_days` | Days log entries are retained (min 1). | `number` | `30` | no |
| `description` | Description of the bucket. | `string` | `null` | no |
| `enable_analytics` | Enable Log Analytics (irreversible). | `bool` | `false` | no |
| `locked` | Lock the retention period (bucket must be emptied before deletion). | `bool` | `false` | no |
| `deletion_policy` | `DELETE`, `PREVENT`, or `ABANDON` on bucket destroy. | `string` | `"DELETE"` | no |
| `kms_key_name` | CMEK key resource name for bucket encryption. | `string` | `null` | no |
| `index_configs` | Custom field indexes (`{ field_path, type }`). | `list(object)` | `[]` | no |
| `create_scope` | Whether to create a log scope. | `bool` | `false` | no |
| `scope_name` | Short name of the log scope (required if `create_scope`). | `string` | `null` | no |
| `scope_resource_names` | Projects/views the scope spans. | `list(string)` | `[]` | no |
| `scope_description` | Description of the log scope. | `string` | `null` | no |
| `scope_deletion_policy` | `DELETE`, `PREVENT`, or `ABANDON` on scope destroy. | `string` | `"DELETE"` | no |
| `sink_name` | Name of the sink created in each source project. | `string` | `"central-logs-sink"` | no |
| `sink_source_projects` | Projects whose logs are routed into the bucket. | `list(string)` | `[]` | no |
| `sink_filter` | Advanced logs filter for every sink (`null` = all logs). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | The `bucket_id` of the log bucket. |
| `bucket_name` | Full resource name of the log bucket. |
| `location` | Location of the log bucket. |
| `scope_id` | Full resource id of the log scope (`null` if not created). |
| `scope_resource_names` | Resources spanned by the scope (`null` if not created). |
| `sink_writer_identities` | Map of source project => sink writer identity granted bucketWriter. |
