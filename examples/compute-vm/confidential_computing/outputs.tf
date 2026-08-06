output "self_link" {
  description = "Self-link to the instance template."
  value       = module.instance_template.self_link
}

output "name" {
  description = "Name of the instance templates."
  value       = module.instance_template.name
}

output "instance_self_link" {
  description = "Self-link for compute instance."
  value       = module.compute_instance.instances_self_links[0]
}

output "suffix" {
  description = "Suffix used as an identifier for resources."
  value       = local.default_suffix
}
