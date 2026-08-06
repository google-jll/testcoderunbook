output "self_link" {
  description = "Self link of the created health check."
  value       = element(concat(local.self_links, [""]), 0)
}

output "id" {
  description = "The id of the created health check."
  value = element(
    concat(
      google_compute_health_check.http[*].id,
      google_compute_health_check.https[*].id,
      google_compute_health_check.tcp[*].id,
      [""],
    ),
    0,
  )
}

output "name" {
  description = "The name of the health check."
  value       = var.name
}

output "type" {
  description = "The protocol of the health check."
  value       = var.type
}
