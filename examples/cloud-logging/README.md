# GCP Cloud Logging Terraform Example

This example demonstrates how to provision **Google Cloud Logging** resources using the [`modules/cloud-logging`](../../modules/cloud-logging) foundation module. Both **Project-level** and **Folder-level** logging are fully supported, as are **BigQuery** and **Cloud Storage** exports, enabling flexible deployment scenarios:
1. **Project-Level Logging Only** (`project_id != null`, `folder_id = null`)
2. **Folder-Level Logging (With Interception)** (`folder_id != null`, `project_id = "central-log-project"`)
3. **Combined Project & Folder Logging** (`project_id != null`, `folder_id != null`)

---

## Storing Logs ONLY in Regional Buckets at Folder Level (No Duplicate Storage)

To achieve **exclusive regional log storage** at the folder level without duplicate storage at the project level:

1. **Child Interception (`intercept_children = true`) on Folder Sink**: Stops child projects' log routers from processing intercepted logs, preventing them from falling into child project `_Default` global buckets.
2. **Disable `_Default` Sink (`disable_default_sink = true`) at Project Level**: Ensures no residual unhandled logs end up in the project's default `_Default` bucket in the `global` region.
3. **Log Routing Architecture**:

```
[ Child Project Logs ] 
       │
       ▼ (Intercepted by Folder Sink: intercept_children = true)
[ logging.googleapis.com/projects/jll-app2 ]
       │
       ▼ (Routed by Project Sink: regional-logs-to-regional-bucket)
[ Regional Log Bucket: us-east1-regional1-app-logs ]
```

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

## Supported Deployment Scenarios

### Scenario A: Project-Level Logging Only (Regional Bucket Only)
Deploy project log sinks routing to custom regional log bucket (`us-central1`), log-based metrics, log exclusions, and disable the project `_Default` sink. BigQuery and GCS exports remain disabled (`null`).

**`terraform.tfvars`**:
```hcl
project_id               = "my-gcp-project-id"
folder_id                = null
disable_default_sink     = true
regional_bucket_location = "us-central1"
regional_bucket_id       = "us-central1-regional-app-logs"
audit_dataset_id         = null
archive_bucket_name      = null
```

### Scenario B: Folder-Level Logging (With Interception)
Deploy folder-level log sinks with `include_children = true` and `intercept_children = true` to intercept and route logs from **ALL child projects** under a GCP folder directly into a central project regional bucket.

> **Note**: GCP Cloud Logging requires `project_id` to be specified so the folder sink knows which central GCP project hosts the regional log bucket.

**`terraform.tfvars`**:
```hcl
project_id               = "my-central-logging-project-id"
folder_id                = "folders/1234567890"
disable_default_sink     = true
regional_bucket_location = "us-east1"
regional_bucket_id       = "us-east1-regional-app-logs"
audit_dataset_id         = null
archive_bucket_name      = null
```

### Scenario C: Full Deployment (Project + Folder + BigQuery & GCS Exports)
Deploy project-level and folder-level regional log buckets along with optional BigQuery SIEM audit export and Cloud Storage long-term log archiving.

**`terraform.tfvars`**:
```hcl
project_id           = "my-gcp-project-id"
folder_id            = "folders/1234567890"
disable_default_sink = true
audit_dataset_id     = "audit_logs_dataset"
archive_bucket_name  = "gcp-syslog-archive-bucket-sample"
```

---

## Features & Scenarios Demonstrated

1. **Custom Regional Log Buckets & Data Residency**:
   - Creates a dedicated regional log bucket in `us-central1` (`us-central1-regional-app-logs`) with 180-day retention and Log Analytics enabled.
   - Routes workload logs matching region filters directly into the dedicated regional bucket via Log Router Sink.
2. **Folder-Level Aggregated & Intercepted Logging (`include_children = true`, `intercept_children = true`)**:
   - Demonstrates folder-wide log interception using `folder_id = "folders/1234567890"`.
   - `regional-folder-interceptor`: Intercepts logs across all child projects and routes them directly to a project destination without duplicate ingestion in child projects.
   - `folder-audit-aggregator`: (Optional) Collects security audit logs from **ALL child projects** into a central BigQuery dataset if `audit_dataset_id` is supplied.
3. **Optional Default Sink Disabling (`disable_default_sink`)**:
   - Provides an optional flag to turn off the GCP default `_Default` global sink, stopping log ingestion into the default global bucket and enforcing regional log storage.
4. **Optional BigQuery & Cloud Storage Export Sinks**:
   - `audit-logs-to-bigquery`: Created only when `audit_dataset_id != null`.
   - `syslog-to-gcs`: Created only when `archive_bucket_name != null`.
5. **Custom Log-based Metrics (Counter & Distribution)**:
   - `security/ssh_unauthorized_attempts`: Counts unauthorized SSH login attempts across VM instances.
   - `compute/gce_error_count`: Counts ERROR and CRITICAL level GCE logs.
   - `app/http_response_latency`: Exponential distribution metric extracting HTTP load balancer response latency.
6. **Project-level Log Ingestion Exclusions**:
   - Drops `DEBUG` severity logs before ingestion at project level to save on Cloud Logging ingestion costs.

---

## Architecture & Resources Created

### Modules Called
- **`module.cloud_logging_project[0]`**: Source `"../../modules/cloud-logging"` (Optional, created when `project_id != null`)
- **`module.cloud_logging_folder[0]`**: Source `"../../modules/cloud-logging"` (Optional, created when `folder_id != null`)

### Resources Provisioned
- **Project Resources** *(Created when `var.project_id` is set)*:
  - `google_logging_project_bucket_config.buckets["regional_app_bucket"]`
  - `google_logging_project_sink.sinks["regional-logs-to-regional-bucket"]`
  - `google_logging_project_sink.sinks["audit-logs-to-bigquery"]` *(optional, when `audit_dataset_id != null`)*
  - `google_logging_project_sink.sinks["syslog-to-gcs"]` *(optional, when `archive_bucket_name != null`)*
  - `google_logging_project_sink.default_sink_override[0]` *(optional when `disable_default_sink = true`)*
  - `google_logging_metric.metrics["ssh_unauthorized_attempts"]`
  - `google_logging_metric.metrics["gce_error_count"]`
  - `google_logging_metric.metrics["http_response_latency"]`
  - `google_logging_project_exclusion.exclusions["drop_debug_logs"]`
- **Folder Resources** *(Created when `var.folder_id` is set)*:
  - `google_logging_folder_sink.folder_sinks["regional-folder-interceptor"]`
  - `google_logging_folder_sink.folder_sinks["folder-audit-aggregator"]` *(optional, when `audit_dataset_id != null`)*

---

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with `roles/logging.admin` on the target project/folder.
- **Required API**: Ensure `logging.googleapis.com` is enabled in your project.

---

## Usage & Execution Steps

```bash
# 1. Navigate to this directory
cd examples/cloud-logging

# 2. Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Set project_id (for project logging), folder_id (for folder logging), or both!

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
| `archive_bucket_name` | Optional Cloud Storage bucket name for long-term log archiving. Set to null if GCS archiving is not needed. | `string` | `null` | No |
| `audit_dataset_id` | Optional BigQuery dataset ID for log sink export destination. Set to null if BigQuery export is not needed. | `string` | `null` | No |
| `disable_default_sink` | Whether to disable the default project _Default log sink to force routing logs to custom regional log buckets. | `bool` | `false` | No |
| `folder_id` | Optional GCP folder ID (e.g. 'folders/123456789' or '123456789') for folder-level log aggregation. | `string` | `null` | No |
| `project_id` | Optional GCP project ID for project-level Cloud Logging resources. | `string` | `null` | No |
| `regional_bucket_id` | Bucket ID for custom regional log bucket. | `string` | `"us-central1-regional-app-logs"` | No |
| `regional_bucket_location` | Location for custom regional log bucket (e.g., us-central1, europe-west1). | `string` | `"us-central1"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `default_sink_disabled` | Boolean indicating whether the default _Default sink was disabled. |
| `folder_buckets` | Created folder-level log bucket details (when folder_id is supplied). |
| `folder_exclusions` | Created folder-level log exclusion objects (when folder_id is supplied). |
| `folder_sink_writer_identities` | Writer identities for folder-level log sinks (when folder_id is supplied). |
| `folder_sinks` | Created folder-level log sink objects (when folder_id is supplied). |
| `log_buckets` | Configured project log bucket details. |
| `log_exclusions` | Created project log exclusion objects. |
| `log_metrics` | Created project log-based metric objects. |
| `sink_writer_identities` | Service account writer identities for created project log sinks. |
