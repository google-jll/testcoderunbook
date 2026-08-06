output "ids" {
  description = "Map of folder name to folder id."
  value       = module.folders.ids
}

output "names" {
  description = "Map of folder name to display name."
  value       = module.folders.names
}
