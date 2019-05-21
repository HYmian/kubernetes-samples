alicloud_access_key = ""

alicloud_secret_key = ""

region = "cn-shenzhen"

availability_zone = "cn-shenzhen-e"

example_name = "terraform-example"

vpc_cidrs = ["192.168.0.0/24"]

vswitch_cidrs = ["192.168.0.0/24"]

worker_instance_type = "ecs.g5.2xlarge"

k8s_pod_cidrs = ["172.20.0.0/16"]

k8s_service_cidrs = ["172.21.0.0/20"]

kube_config = "./config"

client_cert = "./client_cert.pem"

client_key = "./client-key.pem"

cluster_ca_cert = "./cluster-ca-cert.pem"
