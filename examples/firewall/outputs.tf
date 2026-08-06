output "firewall_rules" {
  description = "The created ingress/egress firewall rule resources."
  value       = module.firewall_rules.firewall_rules_ingress_egress
}
