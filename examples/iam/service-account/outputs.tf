output "email" {
  description = "The created service account email."
  value       = module.sa.email
}

output "member" {
  description = "The IAM member string for the service account."
  value       = module.sa.member
}
