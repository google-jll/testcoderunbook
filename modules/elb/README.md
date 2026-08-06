# ELB (External HTTP(S) Load Balancer)

Global external HTTP(S) load-balancer building blocks, vendored from
[`terraform-google-modules/terraform-google-lb-http`](https://github.com/terraform-google-modules/terraform-google-lb-http)
(Apache License 2.0). Each module is standalone in its own directory. Compose
them in your root/deploy config (see [`examples/elb`](../../examples/elb)).

The `serverless_negs` submodule is intentionally omitted.

## Modules

| Module | Description |
|--------|-------------|
| [`elb`](./elb) | The all-in-one HTTP(S) LB module (frontend + backends in one call). |
| [`backend`](./backend) | Backend services / buckets and health checks only. |
| [`frontend`](./frontend) | Global forwarding rules, target proxies, and URL map only. |
| [`dynamic_backends`](./dynamic_backends) | Variant of the LB module that accepts backends as a dynamic map. |

## Usage

```hcl
module "elb" {
  source = "../../modules/elb/elb"
  # ...
}
```
