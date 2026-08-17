locals {
  # Standardize keys provided via key_names (simple list) into the full object structure
  simple_keys = {
    for name in var.key_names : name => {
      purpose                     = "ENCRYPT_DECRYPT"
      rotation_period             = "7776000s" # 90 days
      destroy_scheduled_duration  = "86400s"   # 24 hours
      import_only                 = false
      labels                      = {}
      skip_initial_version_creation = false
      crypto_key_backend          = null
      version_template            = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }
  }

  # Merge detailed keys and simple keys
  all_keys = merge(local.simple_keys, var.keys)

  # Flatten IAM members from shortcut role mappings
  shortcut_roles = {
    "roles/cloudkms.cryptoKeyEncrypterDecrypter" = var.encrypters_decrypters
    "roles/cloudkms.cryptoKeyEncrypter"          = var.encrypters
    "roles/cloudkms.cryptoKeyDecrypter"          = var.decrypters
    "roles/cloudkms.viewer"                     = var.viewers
    "roles/cloudkms.admin"                      = var.admins
  }

  shortcut_iam_members = flatten([
    for role, key_map in local.shortcut_roles : [
      for key_name, members in key_map : [
        for member in members : {
          key        = "${key_name}-${role}-${member}"
          crypto_key = key_name
          role       = role
          member     = member
        }
      ]
    ]
  ])

  custom_iam_members = flatten([
    for key_name, role_map in var.key_iam_members : [
      for role, members in role_map : [
        for member in members : {
          key        = "${key_name}-${role}-${member}"
          crypto_key = key_name
          role       = role
          member     = member
        }
      ]
    ]
  ])

  crypto_key_iam_members = {
    for item in concat(local.shortcut_iam_members, local.custom_iam_members) :
    item.key => item
  }

  key_ring_iam_members = flatten([
    for role, members in var.key_ring_iam_members : [
      for member in members : {
        key    = "${role}-${member}"
        role   = role
        member = member
      }
    ]
  ])
}

resource "google_kms_key_ring" "keyring" {
  name     = var.keyring
  location = var.location
  project  = var.project_id
}

resource "google_kms_crypto_key" "keys" {
  for_each = local.all_keys

  name                          = each.key
  key_ring                      = google_kms_key_ring.keyring.id
  purpose                       = try(each.value.purpose, "ENCRYPT_DECRYPT")
  rotation_period               = (try(each.value.purpose, "ENCRYPT_DECRYPT") == "ENCRYPT_DECRYPT" && try(each.value.import_only, false) != true) ? try(each.value.rotation_period, "7776000s") : null
  destroy_scheduled_duration    = try(each.value.destroy_scheduled_duration, null)
  import_only                   = try(each.value.import_only, false)
  skip_initial_version_creation = try(each.value.skip_initial_version_creation, false)
  crypto_key_backend            = try(each.value.crypto_key_backend, null)
  labels                        = merge(var.labels, try(each.value.labels, {}))

  dynamic "version_template" {
    for_each = try(each.value.version_template, null) != null ? [each.value.version_template] : []
    content {
      algorithm        = try(version_template.value.algorithm, "GOOGLE_SYMMETRIC_ENCRYPTION")
      protection_level = try(version_template.value.protection_level, "SOFTWARE")
    }
  }
}

resource "google_kms_crypto_key_iam_member" "key_iam_members" {
  for_each = {
    for k, v in local.crypto_key_iam_members : k => v
    if contains(keys(google_kms_crypto_key.keys), v.crypto_key)
  }

  crypto_key_id = google_kms_crypto_key.keys[each.value.crypto_key].id
  role          = each.value.role
  member        = each.value.member
}

resource "google_kms_key_ring_iam_member" "keyring_iam_members" {
  for_each = {
    for item in local.key_ring_iam_members : item.key => item
  }

  key_ring_id = google_kms_key_ring.keyring.id
  role        = each.value.role
  member      = each.value.member
}
