locals {
  # Flatten nested tag values for Tag Value resource creation
  tag_values = flatten([
    for key_name, key_config in var.keys : [
      for val_name, val_config in key_config.values : {
        key_name      = key_name
        val_name      = val_name
        description   = val_config.description
        composite_key = "${key_name}/${val_name}"
      }
    ]
  ])

  # Separate global bindings from location-scoped (zonal/regional) bindings
  global_bindings = {
    for k, v in var.bindings : k => v
    if lookup(v, "location", null) == null
  }

  location_bindings = {
    for k, v in var.bindings : k => v
    if lookup(v, "location", null) != null
  }
}

# -------------------------------------------------------------------------------------
# Tag Keys
# -------------------------------------------------------------------------------------
resource "google_tags_tag_key" "keys" {
  for_each = var.keys

  parent       = var.parent
  short_name   = each.key
  description  = each.value.description
  purpose      = each.value.purpose
  purpose_data = each.value.purpose_data
}

# -------------------------------------------------------------------------------------
# Tag Values
# -------------------------------------------------------------------------------------
resource "google_tags_tag_value" "values" {
  for_each = { for item in local.tag_values : item.composite_key => item }

  parent      = google_tags_tag_key.keys[each.value.key_name].id
  short_name  = each.value.val_name
  description = each.value.description
}

# -------------------------------------------------------------------------------------
# Tag Bindings: Global Resources (Projects, Folders, Organizations)
# -------------------------------------------------------------------------------------
resource "google_tags_tag_binding" "global_bindings" {
  for_each = local.global_bindings

  parent = each.value.parent
  tag_value = (
    lookup(each.value, "tag_value_id", null) != null ?
    each.value.tag_value_id :
    google_tags_tag_value.values["${each.value.key_name}/${each.value.val_name}"].id
  )
}

# -------------------------------------------------------------------------------------
# Location Tag Bindings: Zonal/Regional Resources (e.g. Compute Engine VM Instances)
# -------------------------------------------------------------------------------------
resource "google_tags_location_tag_binding" "location_bindings" {
  for_each = local.location_bindings

  parent   = each.value.parent
  location = each.value.location
  tag_value = (
    lookup(each.value, "tag_value_id", null) != null ?
    each.value.tag_value_id :
    google_tags_tag_value.values["${each.value.key_name}/${each.value.val_name}"].id
  )
}

# -------------------------------------------------------------------------------------
# Tag Key IAM Bindings
# -------------------------------------------------------------------------------------
resource "google_tags_tag_key_iam_binding" "key_bindings" {
  for_each = { for item in var.tag_key_iam_bindings : "${item.key_name}-${item.role}" => item }

  tag_key = google_tags_tag_key.keys[each.value.key_name].name
  role    = each.value.role
  members = each.value.members
}

# -------------------------------------------------------------------------------------
# Tag Value IAM Bindings
# -------------------------------------------------------------------------------------
resource "google_tags_tag_value_iam_binding" "value_bindings" {
  for_each = { for item in var.tag_value_iam_bindings : "${item.key_name}/${item.val_name}-${item.role}" => item }

  tag_value = google_tags_tag_value.values["${each.value.key_name}/${each.value.val_name}"].name
  role      = each.value.role
  members   = each.value.members
}
