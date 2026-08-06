provider "google" {
  project = var.project_id
}

locals {
  target_parent = var.parent != null ? var.parent : "projects/${var.project_id}"
}

# -------------------------------------------------------------------------------------
# Invoke Org Policy Module to manage Boolean & List Policies
# -------------------------------------------------------------------------------------
module "org_policy" {
  source = "../../modules/org-policy"

  parent = local.target_parent

  # 1. Boolean Policies (Enable / Disable)
  boolean_policies = {
    # ENABLE / ENFORCE Shielded VM requirement
    "compute.requireShieldedVm" = {
      enforce = true
    }

    # ENABLE / ENFORCE OS Login requirement
    "compute.requireOsLogin" = {
      enforce = true
    }

    # DISABLE / ALLOW Service Account Key Creation (Example of disabling restriction)
    "iam.disableServiceAccountKeyCreation" = {
      enforce = false
    }
  }

  # 2. List Policies (Allowed regions & restricted external IPs)
  list_policies = {
    # Enforce geographic residency / resource locations
    "gcp.resourceLocations" = {
      allow = var.allowed_regions
    }

    # Block external IP address assignment to VMs
    "compute.vmExternalIpAccess" = {
      deny_all = true
    }
  }
}
