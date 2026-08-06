output "self_link_unique" {
  description = "Unique self-link of instance template (recommended output to use instead of self_link)"
  value       = google_compute_instance_template.tpl.self_link_unique
}

output "self_link" {
  description = "Self-link of instance template"
  value       = google_compute_instance_template.tpl.self_link
}

output "name" {
  description = "Name of instance template"
  value       = google_compute_instance_template.tpl.name
}

output "tags" {
  description = "Tags that will be associated with instance(s)"
  value       = google_compute_instance_template.tpl.tags
}

output "service_account_info" {
  description = "Service account id and email"
  value       = local.service_account_output
}

output "network_interface_details" {
  description = "The names of the template interfaces."
  value = [
    for iface in google_compute_instance_template.tpl.network_interface : {
      name = iface.name
    }
  ]
}

