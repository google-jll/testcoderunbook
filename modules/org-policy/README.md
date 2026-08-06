# GCP Organization Policy Module

This module manages **Google Cloud Organization Policies** (`google_org_policy_policy`) at the **Organization**, **Folder**, or **Project** scope. It allows platform administrators and security teams to seamlessly **enable**, **disable**, or **customize** security constraints and guardrails across their GCP resource hierarchy.

---

## Features & Supported Policy Types

- **Boolean Policies (Enable / Disable)**:
  - Enforce policies such as requiring Shielded VMs (`constraints/compute.requireShieldedVm`), requiring OS Login (`constraints/compute.requireOsLogin`), or disabling serial port access (`constraints/compute.disableNestedVirtualization`).
  - Set `enforce = true` to enable/enforce a restriction, or `enforce = false` to explicitly disable/allow it.
- **List Policies (Allow / Deny / Reset)**:
  - Restrict resource deployment locations (`constraints/gcp.resourceLocations`), allowed VM machine types (`constraints/compute.allowedMachineTypes`), or allowed external IP addresses (`constraints/compute.vmExternalIpAccess`).
  - Supports `allow`, `deny`, `allow_all = true`, `deny_all = true`, `inherit_from_parent = true`, and `reset = true`.
- **Multi-Scope Hierarchy**:
  - Scoped to an **Organization** (`organizations/1234567890`), **Folder** (`folders/1234567890`), or **Project** (`projects/my-project-id`).

---

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_org_policy_policy.boolean_policies`**: Creates and applies boolean constraint policies.
- **`google_org_policy_policy.list_policies`**: Creates and applies list constraint policies.

---

## Usage Example

```hcl
module "org_policy" {
  source = "../../modules/org-policy"

  # Target parent scope (Organization, Folder, or Project)
  parent = "projects/${var.project_id}"

  # -----------------------------------------------------------------------------------
  # 1. Boolean Organization Policies
  # -----------------------------------------------------------------------------------
  boolean_policies = {
    # ENABLE / ENFORCE Shielded VMs
    "constraints/compute.requireShieldedVm" = {
      enforce = true
    }

    # ENABLE / ENFORCE OS Login
    "constraints/compute.requireOsLogin" = {
      enforce = true
    }

    # DISABLE / ALLOW Service Account Key Creation (Example of turning off restriction)
    "constraints/iam.disableServiceAccountKeyCreation" = {
      enforce = false
    }
  }

  # -----------------------------------------------------------------------------------
  # 2. List Organization Policies
  # -----------------------------------------------------------------------------------
  list_policies = {
    # Restrict deployment locations strictly to permitted GCP regions
    "constraints/gcp.resourceLocations" = {
      allow = [
        "in:us-locations",
        "in:eu-locations"
      ]
    }

    # Restrict VM external IP address creation to specific instances or deny all
    "constraints/compute.vmExternalIpAccess" = {
      deny_all = true
    }
  }
}
```

---

## Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.3` |
| **Google Cloud Provider** | `>= 5.0, < 8` |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `parent` | Full resource path of the target scope (`organizations/1234567890`, `folders/1234567890`, or `projects/my-project-id`). | `string` | n/a | **Yes** |
| `boolean_policies` | Map of Boolean Org Policies to enforce (`enforce = true`) or disable (`enforce = false`). Key is constraint name. | `map(object)` | `{}` | **No** |
| `list_policies` | Map of List Org Policies configuring allowed/denied values, `allow_all`, `deny_all`, `inherit_from_parent`, or `reset`. | `map(object)` | `{}` | **No** |

---

## Outputs

| Name | Description |
|------|-------------|
| `boolean_policies` | Map of created Boolean Organization Policy resources. |
| `list_policies` | Map of created List Organization Policy resources. |
| `boolean_policy_ids` | Map of constraint names to Boolean Policy resource IDs. |
| `list_policy_ids` | Map of constraint names to List Policy resource IDs. |
