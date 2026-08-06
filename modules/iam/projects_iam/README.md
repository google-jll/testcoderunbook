# GCP Terraform Module: Iam - Projects Iam

This module provisions and manages **Iam - Projects Iam** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_project_iam_binding`** (1 instance): `project_iam_authoritative`
- **`google_project_iam_member`** (1 instance): `project_iam_additive`

### Submodules Called
- **`module.helper`**: `source = "../helper"`

## Usage Example

```hcl
module "projects_iam" {
  source = "../../modules/iam/projects_iam"

  conditional_bindings = var.conditional_bindings
  # projects = []
  # mode = "additive"
  # bindings = {
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
| `projects` | Projects list to add the IAM policies/bindings | `list(string)` | `[]` | No |
| `mode` | Mode for adding the IAM policies/bindings, additive and authoritative | `string` | `"additive"` | No |
| `bindings` | Map of role (key) and list of members (value) to add the IAM policies/bindings | `map(list(string))` | `{` | No |
| `conditional_bindings` | List of maps of role and respective conditions, and the members to add the IAM policies/bindings | `list(object({` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `projects` | Projects wich received bindings. |
| `roles` | Roles which were assigned to members. |
| `members` | Members which were bound to projects. |
