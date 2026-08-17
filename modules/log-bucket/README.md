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
| `bucket_id` | Name of the log bucket. Use a custom name (e.g. \ | `string` | n/a | Yes |
| `project_id` | The GCP project that owns the log bucket (and, if enabled, the log scope). | `string` | n/a | Yes |
| `create_scope` | Whether to create a log scope alongside the bucket. | `bool` | `false` | No |
| `deletion_policy` | How Terraform handles bucket destruction: \ | `string` | `"DELETE"` | No |
| `description` | An optional description for the log bucket. | `string` | `null` | No |
| `enable_analytics` | Enable Log Analytics (BigQuery-backed SQL querying) on the bucket. WARNING: this is irreversible once enabled. | `bool` | `false` | No |
| `index_configs` | Optional list of custom field indexes to speed up queries against structured log fields. | `list(object({ field_path = string type = string }))` | `[]` | No |
| `kms_key_name` | Optional CMEK key resource name to encrypt the bucket (format: projects/<id>/locations/<loc>/keyRings/<ring>/cryptoKeys/<key>). Requires the Cloud Logging service account to have access to the key. | `string` | `null` | No |
| `location` | Location of the log bucket. \ | `string` | `"global"` | No |
| `locked` | Lock the bucket so its retention period cannot be reduced. A locked bucket must be emptied before it can be deleted. | `bool` | `false` | No |
| `retention_days` | Number of days log entries are retained in the bucket (minimum 1). | `number` | `30` | No |
| `scope_deletion_policy` | How Terraform handles log scope destruction: \ | `string` | `"DELETE"` | No |
| `scope_description` | An optional description for the log scope. | `string` | `null` | No |
| `scope_name` | Short name of the log scope (e.g. \ | `string` | `null` | No |
| `scope_resource_names` | Resources the log scope spans. Accepts project ids (projects/<id>) and log views (projects/<id>/locations/<loc>/buckets/<bucket>/views/<view>). Max 50 projects / 100 resources. | `list(string)` | `[]` | No |
| `sink_filter` | Advanced logs filter applied to every sink. Null routes all logs. | `string` | `null` | No |
| `sink_name` | Name of the log sink created in each source project. | `string` | `"central-logs-sink"` | No |
| `sink_source_projects` | Projects whose logs are routed into this bucket. Include this bucket's own project to capture its logs too. The Terraform identity needs logging.sinks permission in every listed project. | `list(string)` | `[]` | No |
## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | The bucket_id of the log bucket. |
| `bucket_name` | The full resource name of the log bucket (projects/<id>/locations/<loc>/buckets/<bucket_id>). |
| `location` | The location of the log bucket. |
| `scope_id` | The full resource id of the log scope, or null when create_scope is false. |
| `scope_resource_names` | The resources spanned by the log scope, or null when create_scope is false. |
| `sink_writer_identities` | Map of source project => the sink's writer identity (granted bucketWriter on the bucket's project). |
