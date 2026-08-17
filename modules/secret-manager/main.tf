locals {
  # Build single secret config if secret_id is specified
  single_secret = var.secret_id != null ? {
    (var.secret_id) = {
      secret_data           = var.secret_data
      secret_data_base64    = var.secret_data_base64
      is_secret_data_base64 = var.is_secret_data_base64
      labels                = var.labels
      annotations           = var.annotations
      expire_time           = var.expire_time
      ttl                   = var.ttl
      version_destroy_ttl   = var.version_destroy_ttl
      version_aliases       = var.version_aliases
      rotation_period       = var.rotation_period
      next_rotation_time    = var.next_rotation_time
      topics                = var.topics
      kms_key_name          = var.kms_key_name
      user_managed_replicas = var.user_managed_replicas
      deletion_policy       = var.deletion_policy
      enabled               = true
      iam_members           = {}
    }
  } : {}

  # Combined secrets map
  all_secrets = merge(local.single_secret, var.secrets)

  # Collect all secret versions to create (only where secret_data or secret_data_base64 is non-null)
  secret_versions = {
    for k, v in local.all_secrets : k => v
    if try(v.secret_data, null) != null || try(v.secret_data_base64, null) != null
  }

  # Build accessors IAM mappings
  accessors_list = can(tolist(var.accessors)) ? tolist(var.accessors) : []
  accessors_map  = can(tomap(var.accessors)) ? tomap(var.accessors) : {}

  accessors_iam = flatten([
    for secret_key in keys(local.all_secrets) : [
      for member in distinct(concat(
        local.accessors_list,
        lookup(local.accessors_map, secret_key, [])
      )) : {
        key       = "${secret_key}-accessor-${member}"
        secret_id = secret_key
        role      = "roles/secretmanager.secretAccessor"
        member    = member
      }
    ]
  ])

  # Per-secret iam_members from var.secrets[secret].iam_members
  secrets_nested_iam = flatten([
    for secret_key, secret_val in local.all_secrets : [
      for role, members in lookup(secret_val, "iam_members", {}) : [
        for member in members : {
          key       = "${secret_key}-${role}-${member}"
          secret_id = secret_key
          role      = role
          member    = member
        }
      ]
    ]
  ])

  # Top-level var.iam_members
  top_level_nested_iam = flatten([
    for secret_key, role_map in var.iam_members : [
      for role, members in role_map : [
        for member in members : {
          key       = "${secret_key}-${role}-${member}"
          secret_id = secret_key
          role      = role
          member    = member
        }
      ]
    ]
  ])

  all_iam_members = {
    for item in concat(local.accessors_iam, local.secrets_nested_iam, local.top_level_nested_iam) :
    item.key => item
  }
}

resource "google_secret_manager_secret" "secrets" {
  for_each = local.all_secrets

  project             = var.project_id
  secret_id           = each.key
  labels              = try(each.value.labels, {})
  annotations         = length(try(each.value.annotations, {})) > 0 ? each.value.annotations : null
  expire_time         = try(each.value.expire_time, null)
  ttl                 = try(each.value.ttl, null)
  version_destroy_ttl = try(each.value.version_destroy_ttl, null)
  version_aliases     = length(try(each.value.version_aliases, {})) > 0 ? each.value.version_aliases : null

  dynamic "rotation" {
    for_each = (try(each.value.next_rotation_time, null) != null && length(try(each.value.topics, [])) > 0) ? [1] : []
    content {
      next_rotation_time = each.value.next_rotation_time
      rotation_period    = try(each.value.rotation_period, null)
    }
  }

  dynamic "topics" {
    for_each = try(each.value.topics, [])
    content {
      name = topics.value
    }
  }

  replication {
    # auto is used when there are no user_managed_replicas AND either no kms key or a global kms key
    dynamic "auto" {
      for_each = (length(try(each.value.user_managed_replicas, [])) == 0 && (try(each.value.kms_key_name, null) == null || can(regex("/locations/global/", try(each.value.kms_key_name, ""))))) ? [1] : []
      content {
        dynamic "customer_managed_encryption" {
          for_each = try(each.value.kms_key_name, null) != null ? [1] : []
          content {
            kms_key_name = each.value.kms_key_name
          }
        }
      }
    }

    # user_managed is used when user_managed_replicas is provided OR a regional (non-global) kms key is used
    dynamic "user_managed" {
      for_each = (length(try(each.value.user_managed_replicas, [])) > 0 || (try(each.value.kms_key_name, null) != null && !can(regex("/locations/global/", try(each.value.kms_key_name, ""))))) ? [1] : []
      content {
        dynamic "replicas" {
          for_each = length(try(each.value.user_managed_replicas, [])) > 0 ? each.value.user_managed_replicas : [
            {
              location     = try(split("/", each.value.kms_key_name)[3], "us-central1")
              kms_key_name = each.value.kms_key_name
            }
          ]
          content {
            location = replicas.value.location
            dynamic "customer_managed_encryption" {
              for_each = (try(replicas.value.kms_key_name, null) != null || try(each.value.kms_key_name, null) != null) ? [coalesce(try(replicas.value.kms_key_name, null), try(each.value.kms_key_name, null))] : []
              content {
                kms_key_name = customer_managed_encryption.value
              }
            }
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "versions" {
  for_each = local.secret_versions

  secret                = google_secret_manager_secret.secrets[each.key].id
  secret_data           = coalesce(try(each.value.secret_data, null), try(each.value.secret_data_base64, null))
  is_secret_data_base64 = try(each.value.is_secret_data_base64, try(each.value.secret_data_base64, null) != null ? true : null)
  enabled               = try(each.value.enabled, true)
  deletion_policy       = try(each.value.deletion_policy, "DELETE")
}

resource "google_secret_manager_secret_iam_member" "members" {
  for_each = {
    for k, v in local.all_iam_members : k => v
    if contains(keys(google_secret_manager_secret.secrets), v.secret_id)
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_id].secret_id
  role      = each.value.role
  member    = each.value.member
}
