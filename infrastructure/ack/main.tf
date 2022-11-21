// Provider specific configs
terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
      version = "1.192.0"
    }
  }
}

provider "alicloud" {
  access_key = var.alicloud_access_key
  secret_key = var.alicloud_secret_key
  region     = var.region
}

// If there is not specifying vpc_id, the module will launch a new vpc
resource "alicloud_vpc" "vpc" {
  count      = length(var.vpc_cidrs)
  cidr_block = var.vpc_cidrs[count.index]
  vpc_name   = format("%s-%s", var.cluster_name, format(var.number_format, count.index + 1))
}

// Instance_types data source for instance_type
data "alicloud_instance_types" "default" {
  cpu_core_count = var.cpu_core_count
  memory_size    = var.memory_size
}

// According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "node_vswitches" {
  count        = length(var.node_vswitch_cidrs)
  vpc_id       = local.vpcs[count.index % length(local.vpcs)]
  cidr_block   = element(var.node_vswitch_cidrs, count.index)
  zone_id      = element(var.availability_zones, count.index)
  vswitch_name = format("%s-node-%s", var.cluster_name, format(var.number_format, count.index + 1))
}

// According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "pod_vswitches" {
  count        = length(var.pod_vswitch_cidrs)
  vpc_id       = local.vpcs[count.index % length(local.vpcs)]
  cidr_block   = element(var.pod_vswitch_cidrs, count.index)
  zone_id      = element(var.availability_zones, count.index)
  vswitch_name = format("%s-pod-%s", var.cluster_name, format(var.number_format, count.index + 1))
}

locals {
  vpcs           = alicloud_vpc.vpc.*.id
  node_vswitches = alicloud_vswitch.node_vswitches.*.id
  pod_vswitches  = alicloud_vswitch.pod_vswitches.*.id
}

resource "alicloud_nat_gateway" "default" {
  count      = var.new_nat_gateway == true ? length(var.vpc_cidrs) : 0
  vpc_id     = local.vpcs[count.index % length(local.vpcs)]
  name       = format("%s-nat-%s", var.cluster_name, format(var.number_format, count.index + 1))
  nat_type   = "Enhanced"
  vswitch_id = local.pod_vswitches[0]
}

resource "alicloud_eip" "default" {
  count     = var.new_nat_gateway == true ? length(var.vpc_cidrs) : 0
  bandwidth = 10
}

resource "alicloud_eip_association" "default" {
  count         = var.new_nat_gateway == true ? length(var.vpc_cidrs) : 0
  allocation_id = alicloud_eip.default.*.id[count.index]
  instance_id   = alicloud_nat_gateway.default.*.id[count.index]
}

resource "alicloud_snat_entry" "node_snat_entry" {
  count             = var.new_nat_gateway == true ? length(alicloud_vswitch.node_vswitches) : 0
  snat_table_id     = alicloud_nat_gateway.default.*.snat_table_ids[floor(count.index / length(local.node_vswitches))]
  source_vswitch_id = local.node_vswitches[count.index]
  # source_vswitch_id = length(var.vswitch_ids) > 0 ? element(split(",", join(",", var.vswitch_ids)), count.index % length(split(",", join(",", var.vswitch_ids)))) : length(var.node_vswitch_cidrs) < 1 ? "" : local.vswitchs[count.index]
  snat_ip    = alicloud_eip.default.*.ip_address[floor(count.index / length(alicloud_vswitch.node_vswitches))]
  depends_on = [alicloud_eip_association.default]
}

resource "alicloud_snat_entry" "pod_snat_entry" {
  count             = var.new_nat_gateway == true ? length(alicloud_vswitch.pod_vswitches) : 0
  snat_table_id     = alicloud_nat_gateway.default.*.snat_table_ids[floor(count.index / length(local.pod_vswitches))]
  source_vswitch_id = local.pod_vswitches[count.index]
  # source_vswitch_id = length(var.vswitch_ids) > 0 ? element(split(",", join(",", var.vswitch_ids)), count.index % length(split(",", join(",", var.vswitch_ids)))) : length(var.node_vswitch_cidrs) < 1 ? "" : local.vswitchs[count.index]
  snat_ip    = alicloud_eip.default.*.ip_address[floor(count.index / length(alicloud_vswitch.pod_vswitches))]
  depends_on = [alicloud_eip_association.default]
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  count                        = length(var.vpc_cidrs)
  name                         = length(var.vpc_cidrs) == 1 ? var.cluster_name : format("%s-%s", var.cluster_name, format(var.number_format, count.index + 1))
  timezone                     = "Asia/Shanghai"
  resource_group_id            = var.resource_group_id
  version                      = var.ack-version
  runtime                      = var.runtime
  is_enterprise_security_group = var.is_enterprise_security_group
  tags = {
    "created_by" : "terraform"
  }
  cluster_spec = var.cluster_spec

  pod_vswitch_ids      = local.pod_vswitches
  new_nat_gateway      = true
  service_cidr         = var.k8s_service_cidrs[count.index]
  slb_internet_enabled = true

  worker_number               = var.k8s_worker_number
  worker_vswitch_ids          = local.node_vswitches
  worker_instance_types       = [var.worker_instance_type == "" ? data.alicloud_instance_types.default.instance_types.0.id : var.worker_instance_type]
  key_name                    = var.key_name
  worker_instance_charge_type = var.worker_instance_charge_type
  worker_disk_category        = var.worker_disk_category
  worker_disk_size            = var.worker_disk_size
  worker_data_disk_category   = var.worker_data_disk_category
  worker_data_disk_size       = var.worker_data_disk_size
  platform                    = "CentOS"
  cpu_policy                  = "none"
  install_cloud_monitor       = false

  kube_config     = var.kube_config
  client_cert     = var.client_cert
  client_key      = var.client_key
  cluster_ca_cert = var.cluster_ca_cert

  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name     = lookup(addons.value, "name", var.cluster_addons)
      config   = lookup(addons.value, "config", var.cluster_addons)
      disabled = lookup(addons.value, "disabled", var.cluster_addons)
    }
  }

  depends_on = [alicloud_snat_entry.node_snat_entry, alicloud_snat_entry.node_snat_entry]
}
