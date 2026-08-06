output "backend_service_info" {
  description = "Host, path and backend service mapping"
  value = concat(!local.is_backend_bucket ? [
    for mapping in var.host_path_mappings : {
      host            = mapping.host
      path            = mapping.path
      backend_service = google_compute_backend_service.default[0].self_link
    }
    ] : [], local.is_backend_bucket ? [for mapping in var.host_path_mappings : {
      host            = mapping.host
      path            = mapping.path
      backend_service = google_compute_backend_bucket.default[0].self_link
    }
    ] : []
  )
}

output "apphub_service_uri" {
  value = concat(
    !local.is_backend_bucket ? [
      {
        service_uri = "//compute.googleapis.com/${google_compute_backend_service.default[0].id}"
        service_id  = substr("${google_compute_backend_service.default[0].name}-${md5("global-be-service-${var.project_id}")}", 0, 63)
        location    = "global"
      }
    ] : [],
  )
  description = "Service URI in CAIS style to be used by Apphub."
}

output "psc_negs" {
  value = !local.is_backend_bucket ? [
    for neg_key, neg in google_compute_region_network_endpoint_group.psc_negs : neg.self_link
  ] : []
  description = "Private Service Connect backends that were created for this backend service"
}
