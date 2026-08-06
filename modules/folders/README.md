# GCP Terraform Module: Folders

This module provisions and manages **Folders** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_folder`** (1 instance): `folders`
- **`google_folder_iam_binding`** (1 instance): `owners_combined`

## Usage Example

```hcl
module "folders" {
  source = "../../modules/folders"

  parent = var.parent
  per_folder_admins = var.per_folder_admins
  # names = []
  # set_roles = false
  # all_folder_admins = []
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
| `parent` | The resource name of the parent Folder or Organization. Must be of the form folders/folder_id or organizations/org_id | `string` | n/a | Yes |
| `names` | Folder names. | `list(string)` | `[]` | No |
| `set_roles` | Enable setting roles via the folder admin variables. | `bool` | `false` | No |
| `per_folder_admins` | n/a | `map(object({` | n/a | Yes |
| `all_folder_admins` | List of IAM-style members that will get the extended permissions across all the folders. | `list(string)` | `[]` | No |
| `prefix` | Optional prefix to enforce uniqueness of folder names. | `string` | `""` | No |
| `folder_admin_roles` | List of roles that will be applied to a folder if roles are not explictly specified in per_folder_admins | `list(string)` | `[` | No |
| `deletion_protection` | Prevent Terraform from destroying or recreating the folder. | `bool` | `true` | No |

## Outputs

| Name | Description |
|------|-------------|
| `folder` | Folder resource (for single use). |
| `id` | Folder id (for single use). |
| `name` | Folder name (for single use). |
| `folders` | Folder resources as list. |
| `folders_map` | Folder resources by name. |
| `ids` | Folder ids. |
| `names` | Folder names. |
| `ids_list` | List of folder ids. |
| `names_list` | List of folder names. |
| `per_folder_admins` | IAM-style members per folder who will get extended permissions. |
