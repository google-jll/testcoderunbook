output "deployment_group_id" {
  description = "The producer's deployment group id. Pass this to the nsi-consumer module/example as producer_dg."
  value       = coalesce(module.nsi_producer.intercept_deployment_group_id, module.nsi_producer.mirroring_deployment_group_id)
}

output "backend_service" {
  description = "Id of the regional backend service fronting the firewalls."
  value       = module.nsi_producer.backend_service
}

output "instance_group_manager" {
  description = "Id of the firewall regional managed instance group."
  value       = module.nsi_producer.instance_group_manager
}
