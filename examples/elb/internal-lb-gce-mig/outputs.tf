output "external_cloudrun_uris" {
  description = "List of URIs for the frontend Cloud Run services"
  value       = [module.frontend-service-a.service_uri, module.frontend-service-b.service_uri]
}
