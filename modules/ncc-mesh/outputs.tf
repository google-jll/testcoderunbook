output "ncc_hub" {
  description = "The NCC Hub object"
  value       = google_network_connectivity_hub.hub
}

output "default_group" {
  description = "The managed `default` group object (null unless auto_accept_projects is set)."
  value       = one(google_network_connectivity_group.default)
}

output "vpc_spokes" {
  description = "All vpc spoke objects"
  value       = local.vpc_spokes
}

output "producer_vpc_network_spoke" {
  description = "All producer network vpc spoke objects"
  value       = local.producer_vpc_network_spoke
}

output "hybrid_spokes" {
  description = "All hybrid spoke objects"
  value       = local.hybrid_spokes
}

output "router_appliance_spokes" {
  description = "All router appliance spoke objects"
  value       = local.router_appliance_spokes
}

output "spokes" {
  description = "All spoke objects prefixed with the type of spoke (vpc, hybrid, appliance)"
  value = flatten([
    {
      for k, v in local.vpc_spokes :
      "vpc/${k}" => v
    },
    {
      for k, v in local.hybrid_spokes :
      "hybrid/${k}" => v
    },
    {
      for k, v in local.router_appliance_spokes :
      "appliance/${k}" => v
    },
    {
      for k, v in local.producer_vpc_network_spoke :
      "producer-vpc/${k}" => v
    },
  ])
}
