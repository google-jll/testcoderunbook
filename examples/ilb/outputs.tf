output "ilb_ip_address" {
  description = "The internal IP assigned to the load balancer forwarding rule."
  value       = module.ilb.ip_address
}

output "forwarding_rule" {
  description = "The forwarding rule self link."
  value       = module.ilb.forwarding_rule
}
