module "ack" {
  source = "./"

  alicloud_access_key = var.alicloud_access_key

  alicloud_secret_key = var.alicloud_secret_key

  region = "cn-wulanchabu"

  vpc_cidrs = ["10.0.0.0/8"]

  cluster_name = "Ulanqab"

  cluster_spec = "ack.pro.small"

  resource_group_id = "rg-aek2ew5qezt5bya"

  ack-version = "1.20.4-aliyun.1"

  availability_zones = ["cn-wulanchabu-a", "cn-wulanchabu-b", "cn-wulanchabu-c"]

  node_vswitch_cidrs = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16"]

  pod_vswitch_cidrs = ["10.3.0.0/16", "10.4.0.0/16", "10.5.0.0/16"]

  k8s_service_cidrs = ["172.21.0.0/20"]

  worker_instance_type = "ecs.g6e.2xlarge"

  worker_disk_category = "cloud_essd"

  worker_data_disk_category = "cloud_essd"

  key_name = "mian-wlcb"

  k8s_worker_number = "0"

  kube_config = "./config"

  client_cert = "./client_cert.pem"

  client_key = "./client-key.pem"

  cluster_ca_cert = "./cluster-ca-cert.pem"
}

module "node_pool" {
  source = "../modules/node_pool"

  alicloud_access_key = var.alicloud_access_key

  alicloud_secret_key = var.alicloud_secret_key

  region = "cn-wulanchabu"

  name = "node_pool"

  vpc_id = module.ack.this_vpc_id

  vswitch_ids = module.ack.this_vswitch_ids

  cluster_id = module.ack.this_k8s_id

  worker_instance_type = "ecs.g6e.2xlarge"

  worker_disk_category = "cloud_essd"

  worker_data_disk_category = "cloud_essd"

  key_name = "mian-wlcb"
}