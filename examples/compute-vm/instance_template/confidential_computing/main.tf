module "instance_template" {
  source = "../../../../modules/compute-vm/instance_template"

  region          = var.region
  project_id      = var.project_id
  service_account = var.service_account
  subnetwork      = var.subnetwork

  name_prefix                = "confidential-template"
  source_image_project       = "ubuntu-os-cloud"
  source_image               = "ubuntu-2004-lts"
  machine_type               = "n2d-standard-2"
  min_cpu_platform           = "AMD Milan"
  enable_confidential_vm     = true
  confidential_instance_type = "SEV"
}
