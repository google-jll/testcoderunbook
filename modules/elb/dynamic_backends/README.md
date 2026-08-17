# GCP Terraform Module: Elb - Dynamic Backends

This module provisions and manages **Elb - Dynamic Backends** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_backend_service`** (1 instance): `default`
- **`google_compute_firewall`** (1 instance): `default-hc`
- **`google_compute_global_address`** (2 instances): `default`, `default_ipv6`
- **`google_compute_global_forwarding_rule`** (4 instances): `http`, `https`, `http_ipv6`, `https_ipv6`
- **`google_compute_health_check`** (1 instance): `default`
- **`google_compute_managed_ssl_certificate`** (1 instance): `default`
- **`google_compute_ssl_certificate`** (1 instance): `default`
- **`google_compute_target_http_proxy`** (1 instance): `default`
- **`google_compute_target_https_proxy`** (1 instance): `default`
- **`google_compute_url_map`** (2 instances): `default`, `https_redirect`
- **`random_id`** (1 instance): `certificate`

## Usage Example

```hcl
module "dynamic_backends" {
  source = "../../modules/elb/dynamic_backends"

  project = var.project
  name = var.name
  backends = var.backends
  certificate_map = var.certificate_map
  # create_address = true
  # address = null
  # enable_ipv6 = false
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
| `backends` | Map backend indices to list of backend maps. | `map(object({ port = optional(number) project = optional(string) protocol = optional(string) port_name = optional(string) description = optional(string) enable_cdn = optional(bool) compression_mode = optional(string) security_policy = optional(string, null) edge_security_policy = optional(string, null) custom_request_headers = optional(list(string)) custom_response_headers = optional(list(string)) timeout_sec = optional(number) connection_draining_timeout_sec = optional(number) session_affinity = optional(string) affinity_cookie_ttl_sec = optional(number) locality_lb_policy = optional(string) health_check = optional(object({ host = optional(string) request_path = optional(string) request = optional(string) response = optional(string) port = optional(number) port_name = optional(string) proxy_header = optional(string) port_specification = optional(string) protocol = optional(string) check_interval_sec = optional(number) timeout_sec = optional(number) healthy_threshold = optional(number) unhealthy_threshold = optional(number) logging = optional(bool) })) log_config = object({ enable = optional(bool) sample_rate = optional(number) }) groups = list(object({ group = string description = optional(string) balancing_mode = optional(string) capacity_scaler = optional(number) max_connections = optional(number) max_connections_per_instance = optional(number) max_connections_per_endpoint = optional(number) max_rate = optional(number) max_rate_per_instance = optional(number) max_rate_per_endpoint = optional(number) max_utilization = optional(number) })) iap_config = optional(object({ enable = bool oauth2_client_id = optional(string) oauth2_client_secret = optional(string) })) cdn_policy = optional(object({ cache_mode = optional(string) signed_url_cache_max_age_sec = optional(string) default_ttl = optional(number) max_ttl = optional(number) client_ttl = optional(number) negative_caching = optional(bool) negative_caching_policy = optional(object({ code = optional(number) ttl = optional(number) })) serve_while_stale = optional(number) cache_key_policy = optional(object({ include_host = optional(bool) include_protocol = optional(bool) include_query_string = optional(bool) query_string_blacklist = optional(list(string)) query_string_whitelist = optional(list(string)) include_http_headers = optional(list(string)) include_named_cookies = optional(list(string)) })) bypass_cache_on_request_headers = optional(list(string)) })) outlier_detection = optional(object({ base_ejection_time = optional(object({ seconds = number nanos = optional(number) })) consecutive_errors = optional(number) consecutive_gateway_failure = optional(number) enforcing_consecutive_errors = optional(number) enforcing_consecutive_gateway_failure = optional(number) enforcing_success_rate = optional(number) interval = optional(object({ seconds = number nanos = optional(number) })) max_ejection_percent = optional(number) success_rate_minimum_hosts = optional(number) success_rate_request_volume = optional(number) success_rate_stdev_factor = optional(number) })) }))` | n/a | Yes |
| `name` | Name for the forwarding rule and prefix for supporting resources | `string` | n/a | Yes |
| `project` | The project to deploy to, if not set the default provider project is used. | `string` | n/a | Yes |
| `address` | Existing IPv4 address to use (the actual IP address value) | `string` | `null` | No |
| `certificate` | Content of the SSL certificate. Requires `ssl` to be set to `true` and `create_ssl_certificate` set to `true` | `string` | `null` | No |
| `certificate_map` | Certificate Map ID in format projects/{project}/locations/global/certificateMaps/{name}. Identifies a certificate map associated with the given target proxy.  Requires `ssl` to be set to `true` | `string` | `null` | No |
| `create_address` | Create a new global IPv4 address | `bool` | `true` | No |
| `create_ipv6_address` | Allocate a new IPv6 address. Conflicts with \ | `bool` | `false` | No |
| `create_ssl_certificate` | If `true`, Create certificate using `private_key/certificate` | `bool` | `false` | No |
| `create_url_map` | Set to `false` if url_map variable is provided. | `bool` | `true` | No |
| `edge_security_policy` | The resource URL for the edge security policy to associate with the backend service | `string` | `null` | No |
| `enable_ipv6` | Enable IPv6 address on the CDN load-balancer | `bool` | `false` | No |
| `firewall_networks` | Names of the networks to create firewall rules in | `list(string)` | `["default"]` | No |
| `firewall_projects` | Names of the projects to create firewall rules in | `list(string)` | `["default"]` | No |
| `http_forward` | Set to `false` to disable HTTP port 80 forward | `bool` | `true` | No |
| `http_keep_alive_timeout_sec` | Specifies how long to keep a connection open, after completing a response, while there is no matching traffic (in seconds). | `number` | `null` | No |
| `http_port` | The port for the HTTP load balancer | `number` | `80` | No |
| `https_port` | The port for the HTTPS load balancer | `number` | `443` | No |
| `https_redirect` | Set to `true` to enable https redirect on the lb. | `bool` | `false` | No |
| `ipv6_address` | An existing IPv6 address to use (the actual IP address value) | `string` | `null` | No |
| `labels` | The labels to attach to resources created by this module | `map(string)` | `{}` | No |
| `load_balancing_scheme` | Load balancing scheme type (EXTERNAL for classic external load balancer, EXTERNAL_MANAGED for Envoy-based load balancer, and INTERNAL_SELF_MANAGED for traffic director) | `string` | `"EXTERNAL"` | No |
| `managed_ssl_certificate_domains` | Create Google-managed SSL certificates for specified domains. Requires `ssl` to be set to `true` | `list(string)` | `[]` | No |
| `network` | Network for INTERNAL_SELF_MANAGED load balancing scheme | `string` | `"default"` | No |
| `private_key` | Content of the private SSL key. Requires `ssl` to be set to `true` and `create_ssl_certificate` set to `true` | `string` | `null` | No |
| `quic` | Specifies the QUIC override policy for this resource. Set true to enable HTTP/3 and Google QUIC support, false to disable both. Defaults to null which enables support for HTTP/3 only. | `bool` | `null` | No |
| `random_certificate_suffix` | Bool to enable/disable random certificate name generation. Set and keep this to true if you need to change the SSL cert. | `bool` | `false` | No |
| `security_policy` | The resource URL for the security policy to associate with the backend service | `string` | `null` | No |
| `server_tls_policy` | The resource URL for the server TLS policy to associate with the https proxy service | `string` | `null` | No |
| `ssl` | Set to `true` to enable SSL support. If `true` then at least one of these are required: 1) `ssl_certificates` OR 2) `create_ssl_certificate` set to `true` and `private_key/certificate` OR  3) `managed_ssl_certificate_domains`, OR 4) `certificate_map` | `bool` | `false` | No |
| `ssl_certificates` | SSL cert self_link list. Requires `ssl` to be set to `true` | `list(string)` | `[]` | No |
| `ssl_policy` | Selfink to SSL Policy | `string` | `null` | No |
| `target_service_accounts` | List of target service accounts for health check firewall rule. Exactly one of target_tags or target_service_accounts should be specified. | `list(string)` | `[]` | No |
| `target_tags` | List of target tags for health check firewall rule. Exactly one of target_tags or target_service_accounts should be specified. | `list(string)` | `[]` | No |
| `url_map` | The url_map resource to use. Default is to send all traffic to first backend. | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `backend_services` | The backend service resources. |
| `external_ip` | The external IPv4 assigned to the global fowarding rule. |
| `external_ipv6_address` | The external IPv6 assigned to the global fowarding rule. |
| `http_proxy` | The HTTP proxy used by this module. |
| `https_proxy` | The HTTPS proxy used by this module. |
| `ipv6_enabled` | Whether IPv6 configuration is enabled on this load-balancer |
| `ssl_certificate_created` | The SSL certificate create from key/pem |
| `url_map` | The default URL map used by this module. |
