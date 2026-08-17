# GCP Cloud Logging Terraform Module

This module manages **Google Cloud Logging** resources at both **Project** and **Folder** levels. Both `project_id` and `folder_id` are optional, allowing flexible single-scope or multi-scope deployments. It supports **Log Router Sinks** (Project & Folder sinks with child aggregation, sink exclusions, custom writer identities), **Regional & Global Log Buckets** (Project & Folder log bucket configs with retention, CMEK encryption, index fields), **Log-based Metrics**, **Log Ingestion Exclusions**, and **Optional Default Sink Disabling** for regional data residency compliance.

---

## Features

- **Project & Folder Log Router Sinks (`google_logging_project_sink`, `google_logging_folder_sink`)**: Exports logs matching specific filter criteria to external storage (GCS), analytics datasets (BigQuery), message streams (PubSub), or regional Log Buckets. Folder-level sinks support `include_children = true` and `intercept_children = true` to intercept and aggregate logs across all child projects in a GCP folder structure.
- **Project & Folder Regional Log Storage (`google_logging_project_bucket_config`, `google_logging_folder_bucket_config`)**: Provisions custom log buckets locked to specific GCP regions (e.g., `us-central1`, `europe-west1`) for strict data localization and sovereignty requirements.
- **Optional Default Sink Override (`disable_default_sink`)**: Allows turning off the automatic project `_Default` log router sink so logs are not stored in the global `_Default` bucket, forcing all log traffic through custom regional log buckets instead.
- **Log-based Metrics (`google_logging_metric`)**: Extracts custom operational metrics from application and system logs for monitoring error frequency, latency distributions (linear/exponential/explicit buckets), or audit triggers.
- **Project & Folder Log Exclusions (`google_logging_project_exclusion`, `google_logging_folder_exclusion`)**: Filters out high-volume, noisy logs at project or folder levels before ingestion to optimize Cloud Logging costs.

---

## Folder Sink Log Routing Mechanics (Option 1 vs. Option 2)

When configuring folder-level log sinks in GCP Cloud Logging, there are two supported architectural patterns:

| Architectural Metric | Option 1: Interception Flow (`intercept_children = true`) | Option 2: Direct Bucket Routing (`intercept_children = false`) |
|---|---|---|
| **Primary Goal** | Stop duplicate log ingestion in child project global `_Default` buckets while enforcing regional storage. | Route folder logs directly to a central regional log bucket URI without child log interception. |
| **GCP API Destination Requirement** | `logging.googleapis.com/projects/<PROJECT_ID>` (Project Destination) | `logging.googleapis.com/projects/<PROJECT_ID>/locations/<LOCATION>/buckets/<BUCKET_ID>` |
| **Prevents Duplicate Logs in Child Projects** | **Yes** (Interceptors stop child project log routers from processing logs) | **No** (Child projects can still process and store logs locally) |
| **Log Flow** | 2-Step GCP Pipeline: Folder Interceptor Sink $\rightarrow$ Target Project Router $\rightarrow$ Project Regional Bucket | 1-Step Direct Route: Folder Sink $\rightarrow$ Target Project Regional Bucket |
| **Final Storage Location** | Dedicated Regional Log Bucket (`us-east1-regional-app-logs`) | Dedicated Regional Log Bucket (`us-east1-regional-app-logs`) |

> [!NOTE]
> GCP Cloud Logging API explicitly requires `intercept_children = true` sinks to route to a Project Destination (`logging.googleapis.com/projects/<PROJECT_ID>`). The project's router sink (`regional-logs-to-regional-bucket`) then delivers the logs into the regional bucket.

---

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_logging_project_sink.sinks`**: Custom project-level router sinks.
- **`google_logging_project_sink.default_sink_override`**: (Optional) Disables default `_Default` global project log router sink.
- **`google_logging_metric`**: Custom log-based counter or distribution metrics.
- **`google_logging_project_bucket_config`**: Configuration for global or regional project log buckets.
- **`google_logging_project_exclusion`**: Project-level log ingestion exclusion rules.
- **`google_logging_folder_sink.folder_sinks`**: Aggregated & intercepted folder-level router sinks exporting child project logs.
- **`google_logging_folder_bucket_config.folder_buckets`**: Configuration for folder log buckets.
- **`google_logging_folder_exclusion.folder_exclusions`**: Folder-level log ingestion exclusion rules.

---

## Deployment Use Cases

### Use Case 1: Project-Level Logging Only

```hcl
module "logging_project" {
  source = "../../modules/cloud-logging"

  project_id           = var.project_id
  disable_default_sink = true

  # Custom Regional Log Bucket
  log_buckets = {
    "us_regional_bucket" = {
      location         = "us-central1"
      bucket_id        = "us-central1-app-logs"
      retention_days   = 180
      enable_analytics = true
      description      = "Regional log bucket in us-central1 for US workload compliance"
    }
  }

  # Route US workload logs to the Regional Log Bucket
  log_sinks = {
    "route-us-logs" = {
      name        = "sink-us-regional-logs"
      destination = "logging.googleapis.com/projects/${var.project_id}/locations/us-central1/buckets/us-central1-app-logs"
      filter      = "resource.labels.location=\"us-central1\""
    }
  }
}
```

### Use Case 2: Folder-Level Logging Only (Aggregating & Intercepting Child Projects)

```hcl
module "logging_folder" {
  source = "../../modules/cloud-logging"

  folder_id = "folders/1234567890"

  # Folder log sink aggregating and intercepting logs from ALL child projects under this folder
  folder_sinks = {
    "prod-folder-interceptor" = {
      name               = "sink-prod-folder-intercepted"
      destination        = "logging.googleapis.com/projects/my-central-log-project"
      filter             = ""
      include_children   = true
      intercept_children = true # Intercepts logs so child project routers do not process them
    }
  }

  # Exclude noisy logs across the entire folder
  folder_exclusions = {
    "drop_folder_debug_logs" = {
      name   = "exclude-debug-severity"
      filter = "severity = DEBUG"
    }
  }
}
```

### Use Case 3: Combined Project & Folder Logging

```hcl
module "logging_combined" {
  source = "../../modules/cloud-logging"

  project_id = "my-gcp-project-id"
  folder_id  = "folders/1234567890"

  log_sinks = {
    "project_sink" = {
      name        = "sink-project-audit"
      destination = "bigquery.googleapis.com/projects/my-gcp-project-id/datasets/audit_ds"
    }
  }

  folder_sinks = {
    "folder_sink" = {
      name               = "sink-folder-aggregated"
      destination        = "storage.googleapis.com/central-folder-log-archive"
      include_children   = true
      intercept_children = true
    }
  }
}
```

---

## Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.3` |
| **Google Cloud Provider** | `>= 5.0, < 8` |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `disable_default_sink` | Optional. Whether to disable the default project _Default log sink to prevent pushing logs to the global _Default bucket, routing logs exclusively to custom regional log buckets. | `bool` | `false` | No |
| `folder_buckets` | Map of Folder Log Bucket configurations. | `map(object({ location = string bucket_id = string folder_id = optional(string) # Optional override if var.folder_id is set globally retention_days = optional(number, 30) description = optional(string) cmek_settings = optional(object({ kms_key_name = string })) index_configs = optional(list(object({ field_path = string type = optional(string, "INDEX_TYPE_STRING") })), []) }))` | `{}` | No |
| `folder_exclusions` | Map of Folder-level Log Exclusions to drop logs across all child projects in a folder. | `map(object({ name = string filter = string folder_id = optional(string) # Optional override if var.folder_id is set globally description = optional(string) disabled = optional(bool, false) }))` | `{}` | No |
| `folder_id` | Optional. The GCP folder ID (e.g. 'folders/123456789' or '123456789') where folder-level Cloud Logging resources will be created. | `string` | `null` | No |
| `folder_sinks` | Map of Folder Log Sinks to export aggregated logs across all child projects in a folder. | `map(object({ name = string destination = string folder_id = optional(string) # Optional override if var.folder_id is set globally filter = optional(string) description = optional(string) disabled = optional(bool, false) include_children = optional(bool, true) # Aggregates logs from all child projects in the folder intercept_children = optional(bool, false) # Intercepts logs so child project log routers do not process them bigquery_options = optional(object({ use_partitioned_tables = bool })) exclusions = optional(list(object({ name = string description = optional(string) filter = string disabled = optional(bool, false) })), []) }))` | `{}` | No |
| `log_buckets` | Map of custom project log bucket configurations (supports global or regional log buckets such as us-central1, europe-west1). | `map(object({ location = string # e.g. "global", "us-central1", "europe-west1" bucket_id = string # e.g. "_Default", "regional-app-logs" retention_days = optional(number, 30) enable_analytics = optional(bool, false) description = optional(string) cmek_settings = optional(object({ kms_key_name = string })) index_configs = optional(list(object({ field_path = string type = optional(string, "INDEX_TYPE_STRING") # "INDEX_TYPE_STRING", "INDEX_TYPE_INTEGER" })), []) }))` | `{}` | No |
| `log_exclusions` | Map of project-level log exclusions to filter out unwanted logs before ingestion. | `map(object({ name = string filter = string description = optional(string) disabled = optional(bool, false) }))` | `{}` | No |
| `log_metrics` | Map of Log-based Metrics to extract metrics from logs at the project level. | `map(object({ name = string filter = string description = optional(string) disabled = optional(bool, false) bucket_name = optional(string) value_extractor = optional(string) # Optional regex extractor for distribution metrics metric_descriptor = optional(object({ metric_kind = string # "DELTA", "GAUGE", "CUMULATIVE" value_type = string # "INT64", "DOUBLE", "DISTRIBUTION" unit = optional(string, "1") })) label_extractors = optional(map(string), {}) bucket_options = optional(object({ linear_buckets = optional(object({ num_finite_buckets = number width = number offset = number })) exponential_buckets = optional(object({ num_finite_buckets = number growth_factor = number scale = number })) explicit_buckets = optional(object({ bounds = list(number) })) })) }))` | `{}` | No |
| `log_sinks` | Map of Project Log Sinks to export logs to Storage, BigQuery, PubSub, or custom regional Log Buckets. | `map(object({ name = string destination = string # e.g. "storage.googleapis.com/my-bucket", "bigquery.googleapis.com/projects/p/datasets/d", "logging.googleapis.com/projects/p/locations/us-central1/buckets/my-regional-bucket" filter = optional(string) description = optional(string) disabled = optional(bool, false) unique_writer_identity = optional(bool, true) # Automatically creates service account writer identity custom_writer_identity = optional(string) # Custom service account identity to write logs bigquery_options = optional(object({ use_partitioned_tables = bool })) exclusions = optional(list(object({ name = string description = optional(string) filter = string disabled = optional(bool, false) })), []) }))` | `{}` | No |
| `project_id` | Optional. The GCP project ID where project-level Cloud Logging resources will be created. | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `default_sink_disabled` | Boolean indicating whether the default _Default sink was disabled. |
| `folder_buckets` | Map of created folder log bucket objects. |
| `folder_exclusions` | Map of created folder log exclusion objects. |
| `folder_sink_writer_identities` | Map of folder sink names to generated writer identity service account emails. |
| `folder_sinks` | Map of created folder log sink objects. |
| `log_buckets` | Map of created/configured project log bucket objects. |
| `log_exclusions` | Map of created project log exclusion objects. |
| `log_metrics` | Map of created log-based metric objects. |
| `sink_writer_identities` | Map of sink names to generated writer identity service account emails. |
| `sinks` | Map of created project log sink objects. |
