output "private_zone_name" {
  description = "Name of the private managed zone."
  value       = module.private_zone.name
}

output "public_zone_name_servers" {
  description = "Name servers for the public zone."
  value       = module.public_zone.name_servers
}

output "forwarding_zone_name" {
  description = "Name of the forwarding zone."
  value       = module.forwarding_zone.name
}

output "peering_zone_name" {
  description = "Name of the peering zone."
  value       = module.peering_zone.name
}
