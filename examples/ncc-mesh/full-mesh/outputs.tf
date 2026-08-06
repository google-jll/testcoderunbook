output "hub" {
  description = "The NCC hub object."
  value       = module.ncc.ncc_hub
}

output "spokes" {
  description = "All spoke objects, keyed by type/name."
  value       = module.ncc.spokes
}
