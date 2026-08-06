# GCP Terraform Module: Elb - Backend

This module provisions and manages **Elb - Backend** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_backend_bucket`** (1 instance): `default`
- **`google_compute_backend_service`** (1 instance): `default`
- **`google_compute_firewall`** (2 instances): `default-hc`, `allow_proxy`
- **`google_compute_health_check`** (1 instance): `default`
- **`google_compute_region_network_endpoint_group`** (2 instances): `serverless_negs`, `psc_negs`
- **`google_iap_web_backend_service_iam_member`** (1 instance): `member`

## Usage Example

```hcl
module "backend" {
  source = "../../modules/elb/backend"

  name = var.name
  project_id = var.project_id
  log_config = var.log_config
  groups = var.groups
  serverless_neg_backends = var.serverless_neg_backends
  psc_neg_backends = var.psc_neg_backends
  iap_config = var.iap_config
  cdn_policy = var.cdn_policy
  outlier_detection = var.outlier_detection
  health_check = var.health_check
  host_path_mappings = var.host_path_mappings
  # load_balancing_scheme = "EXTERNAL_MANAGED"
  # protocol = "HTTP"
  # port_name = "http"
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
| `name` | Name for the backend service. | `string` | n/a | Yes |
| `project_id` | The project to deploy to, if not set the default provider project is used. | `string` | n/a | Yes |
| `load_balancing_scheme` | Load balancing scheme type (EXTERNAL for classic external load balancer, EXTERNAL_MANAGED for Envoy-based load balancer, INTERNAL_MANAGED for internal load balancer and INTERNAL_SELF_MANAGED for traffic director) | `string` | `"EXTERNAL_MANAGED"` | No |
| `protocol` | The protocol this BackendService uses to communicate with backends. | `string` | `"HTTP"` | No |
| `port_name` | Name of backend port. The same name should appear in the instance groups referenced by this service. Required when the load balancing scheme is EXTERNAL. | `string` | `"http"` | No |
| `description` | Description of the backend service. | `string` | `null` | No |
| `enable_cdn` | Enable Cloud CDN for this BackendService. | `bool` | `false` | No |
| `compression_mode` | Compress text responses using Brotli or gzip compression. | `string` | `"DISABLED"` | No |
| `custom_request_headers` | Headers that the HTTP/S load balancer should add to proxied requests. | `list(string)` | `[]` | No |
| `custom_response_headers` | Headers that the HTTP/S load balancer should add to proxied responses. | `list(string)` | `[]` | No |
| `connection_draining_timeout_sec` | Time for which instance will be drained (not accept new connections, but still work to finish started). | `number` | `null` | No |
| `session_affinity` | Type of session affinity to use. Possible values are: NONE, CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, GENERATED_COOKIE, HEADER_FIELD, HTTP_COOKIE, STRONG_COOKIE_AFFINITY. | `string` | `null` | No |
| `affinity_cookie_ttl_sec` | Lifetime of cookies in seconds if session_affinity is GENERATED_COOKIE. | `number` | `null` | No |
| `locality_lb_policy` | The load balancing algorithm used within the scope of the locality. | `string` | `null` | No |
| `timeout_sec` | This has different meaning for different type of load balancing. Please refer https://cloud.google.com/load-balancing/docs/backend-service#timeout-setting | `number` | `null` | No |
| `log_config` | This field denotes the logging options for the load balancer traffic served by this backend service. If logging is enabled, logs will be exported to Stackdriver. | `object({` | n/a | Yes |
| `groups` | The list of backend instance group which serves the traffic. | `list(object({` | n/a | Yes |
| `serverless_neg_backends` | The list of serverless backend which serves the traffic. | `list(object({` | n/a | Yes |
| `psc_neg_backends` | The list of Private Service Connect backends which serve the traffic. | `list(object({` | n/a | Yes |
| `backend_bucket_name` | The name of GCS bucket which serves the traffic. | `string` | `""` | No |
| `iap_config` | Settings for enabling Cloud Identity Aware Proxy and Users/SAs to be given IAP HttpResourceAccessor access to the service. | `object({` | n/a | Yes |
| `cdn_policy` | Cloud CDN configuration for this BackendService. | `object({` | n/a | Yes |
| `outlier_detection` | Settings controlling eviction of unhealthy hosts from the load balancing pool. | `object({` | n/a | Yes |
| `health_check` | Input for creating HttpHealthCheck or HttpsHealthCheck resource for health checking this BackendService. A health check must be specified unless the backend service uses an internet or serverless NEG as a backend. | `object({` | n/a | Yes |
| `edge_security_policy` | The resource URL for the edge security policy to associate with the backend service | `string` | `null` | No |
| `security_policy` | The resource URL for the security policy to associate with the backend service | `string` | `null` | No |
| `host_path_mappings` | The list of host/path for which traffic could be sent to the backend service | `list(object({` | n/a | Yes |
| `firewall_networks` | Names of the networks to create firewall rules in | `list(string)` | `["default"]` | No |
| `firewall_projects` | Names of the projects to create firewall rules in | `list(string)` | `["default"]` | No |
| `target_tags` | List of target tags for health check firewall rule. Exactly one of target_tags or target_service_accounts should be specified. | `list(string)` | `[]` | No |
| `target_service_accounts` | List of target service accounts for health check firewall rule. Exactly one of target_tags or target_service_accounts should be specified. | `list(string)` | `[]` | No |
| `firewall_source_ranges` | Source ranges for the global Application Load Balancer's proxies. This list should contain the `ip_cidr_range` of each GLOBAL_MANAGED_PROXY subnet. | `list(string)` | `["10.127.0.0/23"]` | No |

## Outputs

| Name | Description |
|------|-------------|
| `backend_service_info` | Host, path and backend service mapping |
| `apphub_service_uri` | n/a |
| `psc_negs` | Private Service Connect backends that were created for this backend service |
