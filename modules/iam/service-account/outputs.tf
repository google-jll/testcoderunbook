output "email" {
  description = "The service account email."
  value       = google_service_account.this.email
}

output "id" {
  description = "The service account fully-qualified id (projects/.../serviceAccounts/<email>)."
  value       = google_service_account.this.id
}

output "name" {
  description = "The fully-qualified name of the service account."
  value       = google_service_account.this.name
}

output "member" {
  description = "The IAM member string (serviceAccount:<email>) for use in bindings."
  value       = google_service_account.this.member
}
