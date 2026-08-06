output "bucket_name" {
  description = "Full resource name of the log bucket."
  value       = module.log_bucket.bucket_name
}

output "scope_id" {
  description = "Full resource id of the log scope."
  value       = module.log_bucket.scope_id
}
