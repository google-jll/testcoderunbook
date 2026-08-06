output "load-balancer-ip" {
  value = module.lb-http-frontend.external_ip
}

output "load-balancer-ipv6" {
  value       = module.lb-http-frontend.ipv6_enabled ? module.lb-http-frontend.external_ipv6_address : "undefined"
  description = "The IPv6 address of the load-balancer, if enabled; else \"undefined\""
}
