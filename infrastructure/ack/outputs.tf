// Output kubernetes resource
output "this_k8s_name" {
  description = "Name of the kunernetes cluster."
  value       = concat(alicloud_cs_managed_kubernetes.k8s[*].name, [""])[0]
}
output "this_k8s_id" {
  description = "ID of the kunernetes cluster."
  value       = concat(alicloud_cs_managed_kubernetes.k8s[*].id, [""])[0]
}

output "this_k8s_nodes" {
  description = "List nodes of cluster."
  value       = concat(alicloud_cs_managed_kubernetes.k8s[*].worker_nodes, [""])[0]
}

output "this_k8s_node_ids" {
  description = "List ids of of cluster node."
  value       = [for _, obj in concat(alicloud_cs_managed_kubernetes.k8s[*].worker_nodes, [{}])[0] : lookup(obj,"id")]
}

// Output VPC
output "this_vpc_id" {
  description = "The ID of the VPC."
  value       = concat(alicloud_cs_managed_kubernetes.k8s[*].vpc_id, [""])[0]
}

output "this_vswitch_ids" {
  description = "List ID of the VSwitches."
  value       = local.node_vswitches
}

output "this_security_group_id" {
  description = "ID of the Security Group used to deploy kubernetes cluster."
  value       = concat(alicloud_cs_managed_kubernetes.k8s[*].security_group_id, [""])[0]
}
