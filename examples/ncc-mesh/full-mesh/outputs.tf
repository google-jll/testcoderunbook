output "hub" {
  description = "The NCC hub object."
  value       = module.ncc.ncc_hub
}

output "ncc_hub_id" {
  description = "The full resource ID of the NCC hub."
  value       = module.ncc.ncc_hub_id
}

output "spokes" {
  description = "All spoke objects, keyed by type/name."
  value       = module.ncc.spokes
}
