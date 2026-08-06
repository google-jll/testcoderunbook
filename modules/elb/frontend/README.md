# GCP Terraform Module: Elb - Frontend

This module provisions and manages **Elb - Frontend** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_global_address`** (2 instances): `default`, `default_ipv6`
- **`google_compute_global_forwarding_rule`** (8 instances): `http`, `internal_managed_http`, `https`, `internal_managed_https`, `http_ipv6`, `internal_managed_http_ipv6`, `https_ipv6`, `internal_managed_https_ipv6`
- **`google_compute_managed_ssl_certificate`** (1 instance): `default`
- **`google_compute_ssl_certificate`** (1 instance): `default`
- **`google_compute_target_http_proxy`** (1 instance): `default`
- **`google_compute_target_https_proxy`** (1 instance): `default`
- **`google_compute_url_map`** (2 instances): `https_redirect`, `default`
- **`random_id`** (1 instance): `certificate`

## Usage Example

```hcl
module "frontend" {
  source = "../../modules/elb/frontend"

  name = var.name
  project_id = var.project_id
  url_map_input = var.url_map_input
  certificate_map = var.certificate_map
  internal_forwarding_rules_config = var.internal_forwarding_rules_config
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
| `name` | Name for the forwarding rule and prefix for supporting resources | `string` | n/a | Yes |
| `project_id` | The project to deploy to, if not set the default provider project is used. | `string` | n/a | Yes |
| `create_address` | Create a new global IPv4 address | `bool` | `true` | No |
| `address` | Existing IPv4 address to use (the actual IP address value) | `string` | `null` | No |
| `enable_ipv6` | Enable IPv6 address on the CDN load-balancer | `bool` | `false` | No |
| `create_ipv6_address` | Allocate a new IPv6 address. Conflicts with \ | `bool` | `false` | No |
| `ipv6_address` | An existing IPv6 address to use (the actual IP address value) | `string` | `null` | No |
| `create_url_map` | Set to `false` if url_map variable is provided. | `bool` | `true` | No |
| `url_map_input` | List of host, path and backend service for creating url_map | `list(object({` | n/a | Yes |
| `url_map_resource_uri` | The url_map resource to use. Default is to send all traffic to first backend. | `string` | `null` | No |
| `http_forward` | Set to `false` to disable HTTP port 80 forward | `bool` | `true` | No |
| `ssl` | Set to `true` to enable SSL support. If `true` then at least one of these are required: 1) `ssl_certificates` OR 2) `create_ssl_certificate` set to `true` and `private_key/certificate` OR  3) `managed_ssl_certificate_domains`, OR 4) `certificate_map` | `bool` | `false` | No |
| `create_ssl_certificate` | If `true`, Create certificate using `private_key/certificate` | `bool` | `false` | No |
| `ssl_certificates` | SSL cert self_link list. Requires `ssl` to be set to `true` | `list(string)` | `[]` | No |
| `private_key` | Content of the private SSL key. Requires `ssl` to be set to `true` and `create_ssl_certificate` set to `true` | `string` | `null` | No |
| `certificate` | Content of the SSL certificate. Requires `ssl` to be set to `true` and `create_ssl_certificate` set to `true` | `string` | `null` | No |
| `managed_ssl_certificate_domains` | Create Google-managed SSL certificates for specified domains. Requires `ssl` to be set to `true` | `list(string)` | `[]` | No |
| `certificate_map` | n/a | `string` | n/a | Yes |
| `ssl_policy` | Selfink to SSL Policy | `string` | `null` | No |
| `quic` | Specifies the QUIC override policy for this resource. Set true to enable HTTP/3 and Google QUIC support, false to disable both. Defaults to null which enables support for HTTP/3 only. | `bool` | `null` | No |
| `https_redirect` | Set to `true` to enable https redirect on the lb. | `bool` | `false` | No |
| `random_certificate_suffix` | Bool to enable/disable random certificate name generation. Set and keep this to true if you need to change the SSL cert. | `bool` | `false` | No |
| `labels` | The labels to attach to resources created by this module | `map(string)` | `{` | No |
| `load_balancing_scheme` | Load balancing scheme type (EXTERNAL for classic external load balancer, EXTERNAL_MANAGED for Envoy-based load balancer, INTERNAL_MANAGED for internal load balancer and INTERNAL_SELF_MANAGED for traffic director) | `string` | `"EXTERNAL_MANAGED"` | No |
| `network` | VPC network for the forwarding rule. The VPC network should have exactly one GLOBAL_MANAGED_PROXY subnetwork for every region where the forwarding rule is to be configured. Please go to the subnets tab of your VPC network and check if a GLOBAL_MANAGED_PROXY subnet exists under the `Reserved proxy-only subnets for load balancing` section. If a GLOBAL_MANAGED_PROXY subnet doesn't exist, create one for each required region. | `string` | `"default"` | No |
| `server_tls_policy` | The resource URL for the server TLS policy to associate with the https proxy service | `string` | `null` | No |
| `http_port` | The port for the HTTP load balancer | `number` | `80` | No |
| `https_port` | The port for the HTTPS load balancer | `number` | `443` | No |
| `http_keep_alive_timeout_sec` | Specifies how long to keep a connection open, after completing a response, while there is no matching traffic (in seconds). | `number` | `null` | No |
| `internal_forwarding_rules_config` | List of internal managed forwarding rules config. One of 'address' or 'subnetwork' is required for each. It is only applicable for internal load balancer | `list(object({` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `ip_address_internal_managed_http` | The internal/external IP addresses assigned to the HTTP forwarding rules. |
| `ip_address_internal_managed_https` | The internal/external IP addresses assigned to the HTTPS forwarding rules. |
| `external_ip` | The external IPv4 assigned to the global fowarding rule. |
| `external_ipv6_address` | The external IPv6 assigned to the global fowarding rule. |
| `ipv6_enabled` | Whether IPv6 configuration is enabled on this load-balancer |
| `http_proxy` | The HTTP proxy used by this module. |
| `https_proxy` | The HTTPS proxy used by this module. |
| `url_map` | The default URL map used by this module. |
| `ssl_certificate_created` | The SSL certificate create from key/pem |
| `apphub_service_uri` | n/a |
