output "project_id" {
  value       = var.project_id
  description = "Project ID of the service"
}

output "psc_negs" {
  value       = module.lb-backend-psc-neg.psc_negs
  description = "Psc Neg created for this load balancer"
}
