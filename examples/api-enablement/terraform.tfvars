project_id = "my-non-prod-project-id"

activate_apis = [
  "compute.googleapis.com",
  "networksecurity.googleapis.com",
  "dns.googleapis.com",
  "storage-api.googleapis.com",
  "containerthreatdetection.googleapis.com",
  "dlp.googleapis.com",
  "networkconnectivity.googleapis.com",
  "networkmanagement.googleapis.com",
  "osconfig.googleapis.com",
  "oslogin.googleapis.com",
  "servicedirectory.googleapis.com",
  "websecurityscanner.googleapis.com",
  "iam.googleapis.com",
]

disable_services_on_destroy = true
disable_dependent_services  = true
