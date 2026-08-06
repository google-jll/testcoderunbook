# -------------------------------------------------------------------------------------
# 1. Boolean Organization Policies (Enforce or Disable Constraints)
# -------------------------------------------------------------------------------------
resource "google_org_policy_policy" "boolean_policies" {
  for_each = var.boolean_policies

  name   = "${var.parent}/policies/${each.key}"
  parent = var.parent

  spec {
    inherit_from_parent = each.value.inherit_from_parent
    reset               = each.value.reset

    rules {
      enforce = each.value.enforce ? "TRUE" : "FALSE"
    }
  }
}

# -------------------------------------------------------------------------------------
# 2. List Organization Policies (Allow / Deny / Allow All / Deny All)
# -------------------------------------------------------------------------------------
resource "google_org_policy_policy" "list_policies" {
  for_each = var.list_policies

  name   = "${var.parent}/policies/${each.key}"
  parent = var.parent

  spec {
    inherit_from_parent = each.value.inherit_from_parent
    reset               = each.value.reset

    rules {
      dynamic "values" {
        for_each = (
          each.value.allow != null || each.value.deny != null ? [1] : []
        )
        content {
          allowed_values = each.value.allow
          denied_values  = each.value.deny
        }
      }

      allow_all = each.value.allow_all != null ? (each.value.allow_all ? "TRUE" : "FALSE") : null
      deny_all  = each.value.deny_all != null ? (each.value.deny_all ? "TRUE" : "FALSE") : null
    }
  }
}
