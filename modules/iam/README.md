# IAM

IAM role-binding building blocks, vendored from
[`terraform-google-modules/terraform-google-iam`](https://github.com/terraform-google-modules/terraform-google-iam)
(Apache License 2.0). Each module is standalone in its own directory. Compose
them in your root/deploy config (see [`examples/iam`](../../examples/iam)).

Both binding modules support `mode = "additive"` (non-authoritative,
`google_*_iam_member`) or `mode = "authoritative"` (`google_*_iam_binding`).

## Modules

| Module | Description |
|--------|-------------|
| [`projects_iam`](./projects_iam) | Manage IAM role bindings on one or more projects. |
| [`folders_iam`](./folders_iam) | Manage IAM role bindings on one or more folders. |
| [`helper`](./helper) | Shared helper that expands bindings; used by the binding modules. |

## Usage

```hcl
module "projects_iam" {
  source = "../../modules/iam/projects_iam"

  projects = ["my-project-id"]
  mode     = "additive"
  bindings = {
    "roles/viewer" = ["user:alice@example.com"]
  }
}
```
