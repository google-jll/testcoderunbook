# GCP Terraform Module: Health Check

This module provisions and manages **Health Check** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_health_check`** (3 instances): `http`, `https`, `tcp`

## Usage Example

```hcl
module "health_check" {
  source = "../../modules/health-check"

  project_id = var.project_id
  name = var.name
  # type = "tcp"
  # port = 80
  # request_path = "/"
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
| `project_id` | The GCP project to create the health check in. | `string` | n/a | Yes |
| `name` | Name of the health check. | `string` | n/a | Yes |
| `type` | Protocol of the health check: \ | `string` | `"tcp"` | No |
| `port` | The TCP port number for the health check request. | `number` | `80` | No |
| `request_path` | The request path of the HTTP(S) health check request. Ignored for tcp. | `string` | `"/"` | No |
| `host` | The value of the host header in the HTTP(S) health check request. Ignored for tcp. | `string` | `""` | No |
| `request` | The application data to send once the TCP connection is established. Only used for tcp. | `string` | `""` | No |
| `response` | The bytes to match against the beginning of the response data. | `string` | `""` | No |
| `proxy_header` | The type of proxy header to append before sending data: NONE or PROXY_V1. | `string` | `"NONE"` | No |
| `check_interval_sec` | How often (in seconds) to send a health check. | `number` | `5` | No |
| `timeout_sec` | How long (in seconds) to wait before claiming failure. | `number` | `5` | No |
| `healthy_threshold` | Consecutive successes required to mark an instance healthy. | `number` | `2` | No |
| `unhealthy_threshold` | Consecutive failures required to mark an instance unhealthy. | `number` | `2` | No |
| `enable_logging` | Whether to export health check logs to Cloud Logging. | `bool` | `false` | No |

## Outputs

| Name | Description |
|------|-------------|
| `self_link` | Self link of the created health check. |
| `id` | The id of the created health check. |
| `name` | The name of the health check. |
| `type` | The protocol of the health check. |
