// Provider specific configs
provider "alicloud" {
  access_key = "${var.alicloud_access_key}"
  secret_key = "${var.alicloud_secret_key}"
  region     = "${var.region}"
}

// Instance_types data source for instance_type
data "alicloud_instance_types" "default" {
  cpu_core_count = "${var.cpu_core_count}"
  memory_size    = "${var.memory_size}"
}

// If there is not specifying vpc_id, the module will launch a new vpc
resource "alicloud_vpc" "vpc" {
  count      = "${length(var.vpc_id) > 0 ? 0 : length(var.vpc_cidrs)}"
  cidr_block = "${var.vpc_cidrs[count.index]}"
  name       = "${var.vpc_name == "" ? var.example_name : var.vpc_name}"
}

locals {
  # Ids for multiple sets of EC2 instances, merged together
  vpcs     = "${alicloud_vpc.vpc.*.id}"
  vswitchs = "${alicloud_vswitch.vswitches.*.id}"
}

// According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "vswitches" {
  count             = "${length(var.vswitch_ids) > 0 ? 0 : length(var.vswitch_cidrs)}"
  vpc_id            = "${var.vpc_id == "" ? local.vpcs[count.index%length(local.vpcs)] : var.vpc_id}"
  cidr_block        = "${element(var.vswitch_cidrs, count.index)}"
  availability_zone = "${var.availability_zone}"
  name              = "${var.vswitch_name_prefix == "" ? format("%s-%s", var.example_name, format(var.number_format, count.index+1)) : format("%s-%s", var.vswitch_name_prefix, format(var.number_format, count.index+1))}"
}

resource "alicloud_nat_gateway" "default" {
  count  = "${var.new_nat_gateway == true ? length(var.vpc_cidrs) : 0}"
  vpc_id = "${var.vpc_id == "" ? local.vpcs[count.index%length(local.vpcs)] : var.vpc_id}"
  name   = "${var.nat_gateway_name_prefix == "" ? format("%s-%s", var.example_name, format(var.number_format, count.index+1)) : format("%s-%s", var.nat_gateway_name_prefix, format(var.number_format, count.index+1))}"
}

resource "alicloud_eip" "default" {
  count     = "${var.new_nat_gateway == "true" ? length(var.vpc_cidrs) : 0}"
  bandwidth = 10
}

resource "alicloud_eip_association" "default" {
  count         = "${var.new_nat_gateway == "true" ? length(var.vpc_cidrs) : 0}"
  allocation_id = "${alicloud_eip.default.*.id[count.index]}"
  instance_id   = "${alicloud_nat_gateway.default.*.id[count.index]}"
}

resource "alicloud_snat_entry" "default" {
  count             = "${var.new_nat_gateway == "false" ? 0 : length(var.vpc_cidrs)}"
  snat_table_id     = "${alicloud_nat_gateway.default.*.snat_table_ids[count.index%length(var.vpc_cidrs)]}"
  source_vswitch_id = "${length(var.vswitch_ids) > 0 ? element(split(",", join(",", var.vswitch_ids)), count.index%length(split(",", join(",", var.vswitch_ids)))) : length(var.vswitch_cidrs) < 1 ? "" : local.vswitchs[count.index]}"
  snat_ip           = "${alicloud_eip.default.*.ip_address[count.index%length(var.vpc_cidrs)]}"
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  count                       = "${length(var.vpc_cidrs)}"
  name                        = "${var.k8s_name_prefix == "" ? format("%s-%s", var.example_name, format(var.number_format, count.index+1)) : format("%s-%s", var.k8s_name_prefix, format(var.number_format, count.index+1))}"
  vswitch_ids                 = ["${local.vswitchs[count.index]}"]
  new_nat_gateway             = false
  password                    = "${var.ecs_password}"
  pod_cidr                    = "${var.k8s_pod_cidrs[count.index]}"
  service_cidr                = "${var.k8s_service_cidrs[count.index]}"
  slb_internet_enabled        = true
  install_cloud_monitor       = true
  worker_disk_size            = "${var.worker_disk_size}"
  worker_disk_category        = "${var.worker_disk_category}"
  worker_data_disk_size       = "${var.worker_data_disk_size}"
  worker_data_disk_category   = "${var.worker_data_disk_category}"
  worker_numbers              = ["${var.k8s_worker_number}"]
  worker_instance_types       = ["${var.worker_instance_type == "" ? data.alicloud_instance_types.default.instance_types.0.id : var.worker_instance_type}"]
  worker_instance_charge_type = "${var.worker_instance_charge_type}"
  cluster_network_type        = "${var.cluster_network_type}"
  kube_config                 = "${var.kube_config}"
  client_cert                 = "${var.client_cert}"
  client_key                  = "${var.client_key}"
  cluster_ca_cert             = "${var.cluster_ca_cert}"

  depends_on = ["alicloud_snat_entry.default"]
}
