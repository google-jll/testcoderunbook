output "keys" {
  description = "Map of Tag Key short names to their generated Tag Key IDs (e.g. tagKeys/1234567890)."
  value       = { for k, v in google_tags_tag_key.keys : k => v.id }
}

output "key_names" {
  description = "Map of Tag Key short names to their full resource names."
  value       = { for k, v in google_tags_tag_key.keys : k => v.name }
}

output "values" {
  description = "Map of composite Tag Value keys (key/value) to their generated Tag Value IDs (e.g. tagValues/1234567890)."
  value       = { for k, v in google_tags_tag_value.values : k => v.id }
}

output "values_by_key" {
  description = "Nested map of [key_name][value_name] to Tag Value ID."
  value = {
    for key_name, key_config in var.keys : key_name => {
      for val_name, _ in key_config.values : val_name => google_tags_tag_value.values["${key_name}/${val_name}"].id
    }
  }
}

output "bindings" {
  description = "Map of Tag Binding keys to their generated Tag Binding IDs."
  value = merge(
    { for k, v in google_tags_tag_binding.global_bindings : k => v.id },
    { for k, v in google_tags_location_tag_binding.location_bindings : k => v.id }
  )
}

output "keys_detail" {
  description = "Detailed map of all created Tag Key resources."
  value       = google_tags_tag_key.keys
}

output "values_detail" {
  description = "Detailed map of all created Tag Value resources."
  value       = google_tags_tag_value.values
}
