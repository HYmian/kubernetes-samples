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

resource "alicloud_security_group" "sg" {
  name                = "zl-sg"
  security_group_type = "enterprise"
  inner_access_policy = "Drop"
  vpc_id              = var.vpc_id
}

resource "alicloud_cs_kubernetes_node_pool" "npl" {
  name                 = var.name
  cluster_id           = var.cluster_id
  vswitch_ids          = var.vswitch_ids
  instance_types       = [var.worker_instance_type]
  system_disk_category = var.worker_disk_category
  system_disk_size     = var.worker_disk_size
  data_disks {
    category = var.worker_data_disk_category
    size     = var.worker_data_disk_size
  }
  image_id              = "aliyun_2_1903_x64_20G_alibase_20210325.vhd"
  install_cloud_monitor = false
  key_name              = var.key_name
  security_group_id     = alicloud_security_group.sg.id

  # you need to specify the number of nodes in the node pool, which can be 0
  node_count = 1
}
