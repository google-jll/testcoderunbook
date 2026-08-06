# GCP Terraform Module: Ilb

This module provisions and manages **Ilb** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_firewall`** (2 instances): `default-ilb-fw`, `default-hc`
- **`google_compute_forwarding_rule`** (1 instance): `default`
- **`google_compute_health_check`** (3 instances): `tcp`, `http`, `https`
- **`google_compute_region_backend_service`** (1 instance): `default`

## Usage Example

```hcl
module "ilb" {
  source = "../../modules/ilb"

  project_id = var.project_id
  region = var.region
  subnets = var.subnets
  name = var.name
  backends = var.backends
  health_check = var.health_check
  # global_access = false
  # network = "default"
  # subnetwork = ""
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
| `project_id` | The project_id to deploy to. | `string` | n/a | Yes |
| `region` | Region for cloud resources. | `string` | n/a | Yes |
| `global_access` | Allow all regions on the same VPC network access. | `bool` | `false` | No |
| `network` | Name of the network to create resources in. | `string` | `"default"` | No |
| `subnetwork` | Name of the subnetwork to create resources in. | `string` | `""` | No |
| `subnets` | Optional: A map containing subnet details Used to derive the subnetwork URI if subnetwork is not provided. | `list(object({` | n/a | Yes |
| `network_project` | Name of the project for the network. Useful for shared VPC. Default is var.project_id. | `string` | `""` | No |
| `name` | Name for the forwarding rule and prefix for supporting resources. | `string` | n/a | Yes |
| `backends` | List of backends, should be a map of key-value pairs for each backend, must have the 'group' key. | `list(object({` | n/a | Yes |
| `session_affinity` | The session affinity for the backends example: NONE, CLIENT_IP. Default is `NONE`. | `string` | `"NONE"` | No |
| `ports` | List of ports to forward to backend services. Max is 5. The `ports` or `all_ports` are mutually exclusive. | `list(string)` | `["80"]` | No |
| `all_ports` | Boolean for all_ports setting on forwarding rule. The `ports` or `all_ports` are mutually exclusive. | `bool` | `false` | No |
| `health_check` | Health check to determine whether instances are responsive and able to do work | `object({` | n/a | Yes |
| `source_tags` | List of source tags for traffic between the internal load balancer. | `list(string)` | `["allow-ingress"]` | No |
| `target_tags` | List of target tags for traffic between the internal load balancer. | `list(string)` | `[]` | No |
| `source_ip_ranges` | List of source ip ranges for traffic between the internal load balancer. | `list(string)` | `[]` | No |
| `source_service_accounts` | List of source service accounts for traffic between the internal load balancer. | `list(string)` | `null` | No |
| `target_service_accounts` | List of target service accounts for traffic between the internal load balancer. | `list(string)` | `null` | No |
| `ip_address` | IP address of the internal load balancer, if empty one will be assigned. Default is empty. | `string` | `null` | No |
| `ip_protocol` | The IP protocol for the backend and frontend forwarding rule. TCP or UDP. | `string` | `"TCP"` | No |
| `service_label` | Service label is used to create internal DNS name | `string` | `null` | No |
| `connection_draining_timeout_sec` | Time for which instance will be drained | `number` | `null` | No |
| `create_backend_firewall` | Controls if firewall rules for the backends will be created or not. Health-check firewall rules are controlled separately. | `bool` | `true` | No |
| `create_health_check_firewall` | Controls if firewall rules for the health check will be created or not. If this rule is not present backend healthcheck will fail. | `bool` | `true` | No |
| `firewall_enable_logging` | Controls if firewall rules that are created are to have logging configured. This will be ignored for firewall rules that are not created. | `bool` | `false` | No |
| `labels` | The labels to attach to resources created by this module. | `string` | `{` | No |
| `is_mirroring_collector` | Indicates whether or not this load balancer can be used as a collector for packet mirroring. This can only be set to true for load balancers that have their loadBalancingScheme set to INTERNAL. | `bool` | `false` | No |

## Outputs

| Name | Description |
|------|-------------|
| `ip_address` | The internal IP assigned to the regional forwarding rule. |
| `forwarding_rule` | The forwarding rule self_link. |
| `forwarding_rule_id` | The forwarding rule id. |
