# common variables
variable "alicloud_access_key" {
  description = "The Alicloud Access Key ID to launch resources."
}

variable "alicloud_secret_key" {
  description = "The Alicloud Access Secret Key to launch resources."
}

variable "region" {
  description = "The region to launch resources."
  default     = "cn-hangzhou"
}

variable "cluster_name" {
  default = "tf-kubernetes"
}

variable "cluster_spec" {
  default = "ack.standard"
}

variable "number_format" {
  description = "The number format used to output."
  default     = "%02d"
}

variable "resource_group_id" {
  description = "The ID of the resource group, by default these cloud resources are automatically assigned to the default resource group."
  default     = ""
}

variable "ack-version" {
  description = "Desired Kubernetes version."
  default     = "1.18.1-aliyun.1"
}

variable "runtime" {
  description = "The runtime of containers."
  default = {
    name = "docker"
    # version = "19.03.5"
  }
}

variable "is_enterprise_security_group" {
  description = "Enable to create advanced security group."
  default     = true
}

variable "tags" {
  description = "A map of tags assigned to the kubernetes cluster."
  default     = {}
}

variable "proxy_mode" {
  description = "Proxy mode is option of kube-proxy. options: iptables|ipvs."
  default     = "ipvs"
}

variable "image_id" {
  description = "Custom Image support. Must based on CentOS7 or AliyunLinux2."
  default     = ""
}

variable "cluster_domain" {
  description = "Cluster local domain name."
  default     = "cluster.local"
}

variable "service_account_issuer" {
  description = "The issuer of the Service Account token for Service Account Token Volume Projection, corresponds to the iss field in the token payload."
  default     = ""
}

variable "api_audiences" {
  description = "A list of API audiences for Service Account Token Volume Projection."
  default     = ""
}

variable "availability_zones" {
  description = "The available zone to launch ecs instance and other resources."
  type        = list(any)
  default     = []
}

# Instance typs variables
variable "cpu_core_count" {
  description = "CPU core count is used to fetch instance types."
  default     = 4
}
variable "memory_size" {
  description = "Memory size used to fetch instance types."
  default     = 8
}

variable "vpc_cidrs" {
  description = "The cidr block used to launch a new vpc when 'vpc_id' is not specified."
  type        = list(any)
  default     = []
}

variable "node_vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches for node."
  type        = list(any)
  default     = []
}

variable "pod_vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches for pod."
  type        = list(any)
  default     = []
}

variable "pod_cidrs" {
  description = "List of cidr blocks for pod."
  type        = list(any)
  default     = []
}

variable "new_nat_gateway" {
  description = "Whether to create a new nat gateway. In this template, a new nat gateway will create a nat gateway, eip and server snat entries."
  default     = true
}

# Cluster nodes variables
variable "worker_instance_type" {
  description = "The ecs instance type used to launch worker nodes. Default from instance typs datasource."
  default     = ""
}

variable "worker_disk_category" {
  description = "The system disk category used to launch one or more worker nodes."
  default     = "cloud_efficiency"
}

variable "worker_disk_size" {
  description = "The system disk size used to launch one or more worker nodes."
  default     = "40"
}

variable "worker_data_disk_category" {
  description = "The data disk category used to launch one or more worker nodes."
  default     = "cloud_efficiency"
}

variable "worker_data_disk_size" {
  description = "The data disk size used to launch one or more worker nodes."
  default     = "100"
}

variable "ecs_password" {
  description = "The password of instance."
  default     = "Abc12345"
}

variable "key_name" {
  description = "The key of instance."
  default     = ""
}

variable "k8s_worker_number" {
  description = "The number of worker nodes in each kubernetes cluster."
  default     = 3
}

variable "k8s_service_cidrs" {
  description = "The kubernetes service cidr block. It cannot be equals to vpc's or vswitch's or pod's and cannot be in them."
  type        = list(any)
  default     = []
}

variable "worker_instance_charge_type" {
  description = "Worker payment type. PrePaid or PostPaid, defaults to PostPaid."
  default     = "PostPaid"
}

variable "kube_config" {
  description = "The path of kube config"
  default     = "./config"
}

variable "client_cert" {
  description = "The path of client certificate"
  default     = "./client-cert.pem"
}

variable "client_key" {
  description = "The path of client key"
  default     = "./client-key.pem"
}

variable "cluster_ca_cert" {
  description = "The path of cluster ca certificate"
  default     = "./cluster-ca-cert.pem"
}

variable "cluster_addons" {
  description = "Addon components in kubernetes cluster"

  type = list(object({
    name     = string
    config   = string
    disabled = bool
  }))

  default = [
    {
      "name"     = "terway-eniip",
      "config"   = "",
      "disabled" = false,
    },
    {
      "name"     = "csi-plugin",
      "config"   = "",
      "disabled" = false,
    },
    {
      "name"     = "csi-provisioner",
      "config"   = "",
      "disabled" = false,
    },
    {
      "name"     = "logtail-ds",
      "config"   = "{\"IngressDashboardEnabled\":\"true\",\"sls_project_name\":\"\"}",
      "disabled" = false,
    },
    {
      "name"     = "nginx-ingress-controller",
      "config"   = "{\"IngressSlbNetworkType\":\"internet\"}",
      "disabled" = false,
    },
    {
      "name"     = "arms-prometheus",
      "config"   = "",
      "disabled" = false,
    }
  ]
}
